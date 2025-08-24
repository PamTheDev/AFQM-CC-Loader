// --- Imports ---
using System;
using System.IO;
using System.Threading.Tasks;
using System.Linq;
using System.Collections.Generic;
using System.Drawing;
using System.Text.RegularExpressions;
using System.Windows.Forms;
using ImageMagick;
using UndertaleModLib.Util;
using UndertaleModLib.Models;
using UndertaleModLib.Compiler;
using System.Collections;
using System.IO.Compression;



// --- Progress Bar Helper ---
Form progressForm = new Form()
{
    Size = new Size(400, 100),
    Text = "Import Progress",
    FormBorderStyle = FormBorderStyle.FixedDialog,
    MaximizeBox = false,
    MinimizeBox = false,
    StartPosition = FormStartPosition.CenterScreen
};
Label progressLabel = new Label()
{
    AutoSize = false,
    Dock = DockStyle.Fill,
    TextAlign = ContentAlignment.MiddleCenter,
    Font = new Font("Segoe UI", 12, FontStyle.Bold)
};
progressForm.Controls.Add(progressLabel);
progressForm.Show();
void UpdateProgress(string step)
{
    progressLabel.Text = step;
    progressForm.Refresh();
    Application.DoEvents();
}

// --- Ensure Data Loaded ---
EnsureDataLoaded();


// --- Ask for Import Folder ---
string importFolder = PromptChooseDirectory();
if (importFolder == null)
    throw new ScriptException("The import folder was not set.");

// --- Delete specific files if they exist in the import folder ---
string[] filesToDelete = {
            "gml_GlobalScript_character_data.gml", // GML script for character data
            "gml_Object_obj_css_portraits_list_Create_0.gml" // GML script for CSS portraits
};
foreach (var fileName in filesToDelete)
{
    string filePath = Path.Combine(importFolder, fileName);
    if (File.Exists(filePath))
    {
        try { File.Delete(filePath); }
        catch (Exception ex) { MessageBox.Show($"Failed to delete {fileName}: {ex.Message}"); }
    }
}



// --- 2. Import Graphics (sprites/backgrounds) ---
// The following is a minimal call to the ImportGraphicsAdvanced logic.
// We'll call the CheckValidity() function from ImportGraphicsAdvanced, but override the folder to use the one already selected.

static bool importAsSprite = true;
static bool importFrameless = true; // Always import frameless images as single-frame sprites
string[] offsets = { "Center" };
string[] playbacks = { "Frames Per Game Frame" };
static List<MagickImage> imagesToCleanup = new();
float animSpd = 1;
bool isSpecial = false;
uint specialVer = 1;
string offresult = "Center"; // Default origin
int playback = 0; // Default to "Frames Per Game Frame"
HashSet<string> spritesStartAt1 = new HashSet<string>();
bool createCollisionMasks = false;

// --- Use CheckValidity from ImportGraphicsAdvanced, but skip folder prompt ---
string packDir = Path.Combine(ExePath, "Packager");
Directory.CreateDirectory(packDir);

bool noMasksForBasicRectangles = Data.IsVersionAtLeast(2022, 9); // TODO: figure out the exact version, but this is pretty close

// --- Check for valid images and ask user for sprite import options ---
bool recursiveCheck = true;
if (!recursiveCheck)
    throw new ScriptException("Script cancelled.");

//Stop the script if there's missing sprite entries or w/e.
bool hadMessage = false;
bool hadFramelessMessage = false;
string[] dirFiles = Directory.GetFiles(importFolder, "*.png", SearchOption.AllDirectories);
foreach (string file in dirFiles)
{
    string FileNameWithExtension = Path.GetFileName(file);
    string stripped = Path.GetFileNameWithoutExtension(file);
    int lastUnderscore = stripped.LastIndexOf('_');
    string spriteName = "";

    SpriteType spriteType = GetSpriteType(file);

    if ((spriteType != SpriteType.Sprite) && (spriteType != SpriteType.Background))
    {
        if (!hadMessage)
        {
            hadMessage = true;
            importAsSprite = true;
        }

        if (!importAsSprite)
        {
            continue;
        }
        else
        {
            spriteType = SpriteType.Sprite;
        }
    }

    // Check for duplicate filenames
    string[] dupFiles = Directory.GetFiles(importFolder, FileNameWithExtension, SearchOption.AllDirectories);
    if (dupFiles.Length > 1)
        throw new ScriptException("Duplicate file detected. There are " + dupFiles.Length + " files named: " + FileNameWithExtension);

    // Sprites can have multiple frames! Do some sprite-specific checking.
    if (spriteType == SpriteType.Sprite)
    {
        Match stripMatch = Regex.Match(stripped, @"(.*)_strip(\d+)");
        if (stripMatch.Success)
        {
            string frameCountStr = stripMatch.Groups[2].Value;

            int frames;
            try
            {
                frames = Int32.Parse(frameCountStr);
            }
            catch
            {
                throw new ScriptException(FileNameWithExtension + " has an invalid strip numbering scheme. Script has been stopped.");
            }
            if (frames <= 0)
            {
                throw new ScriptException(FileNameWithExtension + " has 0 frames. Script has been stopped.");
            }

            // Probably a valid strip, can continue
            continue;
        }

        try
        {
            spriteName = stripped.Substring(0, lastUnderscore);

            // Check if the frame number is a valid string or not
            Int32.Parse(stripped.Substring(lastUnderscore + 1));
        }
        catch
        {
            if (!hadFramelessMessage)
            {
                importFrameless = true;
                hadFramelessMessage = true;
            }
            if (importFrameless)
            {
                spriteName = stripped;
            }
            else
            {
                continue;
            }
        }

        // If the sprite doesn't have an underscore, don't bother trying to parse it since it'll be single-frame anyways
        int frame = 0;
        if (spriteName != stripped)
        {
            Int32 validFrameNumber = 0;
            try
            {
                validFrameNumber = Int32.Parse(stripped.Substring(lastUnderscore + 1));
            }
            catch
            {
                if (!hadFramelessMessage)
                {
                    importFrameless = ScriptQuestion(FileNameWithExtension + @" does not seem to have a frame number or count. Import this image as a single-frame sprite named " + stripped + @"?
    Pressing ""No"" will cause the program to ignore these images.");
                    hadFramelessMessage = true;
                }
                if (importFrameless)
                {
                    spriteName = stripped;
                }
                else
                {
                    continue;
                }
            }
            try
            {
                frame = Int32.Parse(stripped.Substring(lastUnderscore + 1));
            }
            catch
            {
                throw new ScriptException(FileNameWithExtension + " is using letters instead of numbers. The script has stopped for your own protection.");
            }
        }

        int prevframe = 0;
        if (frame > 0)
        {
            prevframe = (frame - 1);
        }
        else if (frame < 0)
        {
            throw new ScriptException(spriteName + " is using an invalid numbering scheme. The script has stopped for your own protection.");
        }
        else
        {
            continue;
        }
        string prevFrameName = spriteName + "_" + prevframe.ToString() + ".png";
        string[] previousFrameFiles = Directory.GetFiles(importFolder, prevFrameName, SearchOption.AllDirectories);
        if (previousFrameFiles.Length < 1)
        {
            if (frame == 1)
            {
                spritesStartAt1.Add(spriteName);
            }
            else
            {
                throw new ScriptException(spriteName + " is missing one or more indexes. The detected missing index is: " + prevFrameName);
            }
        }
    }
}

// --- Ask for sprite import parameters ---
OffsetResult(); // Prompt user for sprite import parameters

// --- Now run the graphics import logic with improved hurtbox importing ---
UpdateProgress("Importing graphics (sprites/backgrounds)...");
try
{
    string sourcePath = importFolder;
    string outName = Path.Combine(packDir, "atlas.txt");
    int textureSize = 2048;
    int PaddingValue = 2;
    bool debug = false;
    Packer packer = new Packer();
    packer.Process(sourcePath, textureSize, PaddingValue, debug);
    packer.SaveAtlasses(outName);

    int lastTextPage = Data.EmbeddedTextures.Count - 1;
    int lastTextPageItem = Data.TexturePageItems.Count - 1;

    bool bboxMasks = Data.IsVersionAtLeast(2024, 6);
    Dictionary<UndertaleSprite, Dictionary<int, Node>> maskNodeLookup = new();

    // Import everything into UTMT
    string prefix = outName.Replace(Path.GetExtension(outName), "");
    int atlasCount = 0;
    foreach (Atlas atlas in packer.Atlasses)
    {
        string atlasName = Path.Combine(packDir, $"{prefix}{atlasCount:000}.png");
        using MagickImage atlasImage = TextureWorker.ReadBGRAImageFromFile(atlasName);
        IPixelCollection<byte> atlasPixels = atlasImage.GetPixels();

        UndertaleEmbeddedTexture texture = new();
        texture.Name = new UndertaleString($"Texture {++lastTextPage}");
        texture.TextureData.Image = GMImage.FromMagickImage(atlasImage).ConvertToPng();
        Data.EmbeddedTextures.Add(texture);
        foreach (Node n in atlas.Nodes)
        {
            if (n.Texture != null)
            {
                // Initalize values of this texture
                UndertaleTexturePageItem texturePageItem = new UndertaleTexturePageItem();
                texturePageItem.Name = new UndertaleString("PageItem " + ++lastTextPageItem);
                texturePageItem.SourceX = (ushort)n.Bounds.X;
                texturePageItem.SourceY = (ushort)n.Bounds.Y;
                texturePageItem.SourceWidth = (ushort)n.Bounds.Width;
                texturePageItem.SourceHeight = (ushort)n.Bounds.Height;

                // Special handling for palette textures
                string texFileName = n.Texture.Source.ToLower();
                if (texFileName.Contains("_palette"))
                {
                    // Set bounding box and target position to match sprite size and (0,0)
                    // Try to get the sprite for this texture if possible
                    string spriteName = Path.GetFileNameWithoutExtension(n.Texture.Source);
                    UndertaleSprite spr = Data.Sprites.ByName(spriteName);
                    if (spr != null)
                    {
                        texturePageItem.BoundingWidth = (ushort)spr.Width;
                        texturePageItem.BoundingHeight = (ushort)spr.Height;
                        texturePageItem.TargetWidth = (ushort)spr.Width;
                        texturePageItem.TargetHeight = (ushort)spr.Height;
                    }
                    else
                    {
                        // fallback to node bounds if sprite not found
                        texturePageItem.BoundingWidth = (ushort)n.Bounds.Width;
                        texturePageItem.BoundingHeight = (ushort)n.Bounds.Height;
                        texturePageItem.TargetWidth = (ushort)n.Bounds.Width;
                        texturePageItem.TargetHeight = (ushort)n.Bounds.Height;
                    }
                    texturePageItem.TargetX = 0;
                    texturePageItem.TargetY = 0;
                }
                else
                {
                    texturePageItem.TargetX = (ushort)n.Texture.TargetX;
                    texturePageItem.TargetY = (ushort)n.Texture.TargetY;
                    texturePageItem.TargetWidth = (ushort)n.Bounds.Width;
                    texturePageItem.TargetHeight = (ushort)n.Bounds.Height;
                    texturePageItem.BoundingWidth = (ushort)n.Texture.BoundingWidth;
                    texturePageItem.BoundingHeight = (ushort)n.Texture.BoundingHeight;
                }
                texturePageItem.TexturePage = texture;

                // Add this texture to UMT
                Data.TexturePageItems.Add(texturePageItem);

                // String processing
                string stripped = Path.GetFileNameWithoutExtension(n.Texture.Source);

                SpriteType spriteType = GetSpriteType(n.Texture.Source);

                if (importAsSprite)
                {
                    if ((spriteType == SpriteType.Unknown) || (spriteType == SpriteType.Font))
                    {
                        spriteType = SpriteType.Sprite;
                    }
                }

                if (spriteType == SpriteType.Background)
                {
                    UndertaleBackground background = Data.Backgrounds.ByName(stripped);
                    if (background != null)
                    {
                        background.Texture = texturePageItem;
                    }
                    else
                    {
                        // No background found, let's make one
                        UndertaleString backgroundUTString = Data.Strings.MakeString(stripped);
                        UndertaleBackground newBackground = new UndertaleBackground();
                        newBackground.Name = backgroundUTString;
                        newBackground.Transparent = false;
                        newBackground.Preload = false;
                        newBackground.Texture = texturePageItem;
                        Data.Backgrounds.Add(newBackground);
                    }
                }
                else if (spriteType == SpriteType.Sprite)
                {
                    // Get sprite to add this texture to
                    string spriteName;
                    int lastUnderscore, frame;
                    try
                    {
                        lastUnderscore = stripped.LastIndexOf('_');
                        Int32.Parse(stripped.Substring(lastUnderscore + 1));
                        spriteName = stripped.Substring(0, lastUnderscore);
                        frame = Int32.Parse(stripped.Substring(lastUnderscore + 1));
                    }
                    catch (Exception e)
                    {
                        if (!importFrameless)
                        {
                            continue;
                        }
                        spriteName = stripped;
                        frame = 0;
                    }

                    var isHurtbox = spriteName.EndsWith("_hb");

                    if (spritesStartAt1.Contains(spriteName))
                    {
                        frame--;
                    }

                    // Create TextureEntry object
                    UndertaleSprite.TextureEntry texentry = new UndertaleSprite.TextureEntry();
                    texentry.Texture = texturePageItem;

                    // Set values for new sprites
                    UndertaleSprite sprite = Data.Sprites.ByName(spriteName);
                    if (sprite is null)
                    {
                        UndertaleString spriteUTString = Data.Strings.MakeString(spriteName);
                        UndertaleSprite newSprite = new UndertaleSprite();
                        newSprite.Name = spriteUTString;
                        newSprite.Width = (uint)n.Texture.BoundingWidth;
                        newSprite.Height = (uint)n.Texture.BoundingHeight;
                        newSprite.MarginLeft = n.Texture.TargetX;
                        newSprite.MarginRight = n.Texture.TargetX + n.Bounds.Width - 1;
                        newSprite.MarginTop = n.Texture.TargetY;
                        newSprite.MarginBottom = n.Texture.TargetY + n.Bounds.Height - 1;
                        newSprite.GMS2PlaybackSpeedType = (AnimSpeedType)playback;
                        newSprite.GMS2PlaybackSpeed = animSpd;
                        newSprite.IsSpecialType = isSpecial;
                        newSprite.SVersion = specialVer;

                        if (isHurtbox)
                            newSprite.SepMasks = UndertaleSprite.SepMaskType.Precise;

                        switch (offresult)
                        {
                            case ("Top Left"):
                                newSprite.OriginX = 0;
                                newSprite.OriginY = 0;
                                break;
                            case ("Top Center"):
                                newSprite.OriginX = (int)(newSprite.Width / 2);
                                newSprite.OriginY = 0;
                                break;
                            case ("Top Right"):
                                newSprite.OriginX = (int)(newSprite.Width);
                                newSprite.OriginY = 0;
                                break;
                            case ("Center Left"):
                                newSprite.OriginX = 0;
                                newSprite.OriginY = (int)(newSprite.Height / 2);
                                break;
                            case ("Center"):
                                newSprite.OriginX = (int)(newSprite.Width / 2);
                                newSprite.OriginY = (int)(newSprite.Height / 2);
                                break;
                            case ("Center Right"):
                                newSprite.OriginX = (int)(newSprite.Width);
                                newSprite.OriginY = (int)(newSprite.Height / 2);
                                break;
                            case ("Bottom Left"):
                                newSprite.OriginX = 0;
                                newSprite.OriginY = (int)(newSprite.Height);
                                break;
                            case ("Bottom Center"):
                                newSprite.OriginX = (int)(newSprite.Width / 2);
                                newSprite.OriginY = (int)(newSprite.Height);
                                break;
                            case ("Bottom Right"):
                                newSprite.OriginX = (int)(newSprite.Width);
                                newSprite.OriginY = (int)(newSprite.Height);
                                break;
                        }
                        if (frame > 0)
                        {
                            for (int i = 0; i < frame; i++)
                                newSprite.Textures.Add(null);
                        }

                        // Only generate collision masks for sprites that need them (in newer GameMaker versions)
                        if (isHurtbox && createCollisionMasks)
                        {
                            maskNodeLookup.Add(newSprite, new() { { frame, n } });
                        }

                        newSprite.Textures.Add(texentry);
                        Data.Sprites.Add(newSprite);
                        continue;
                    }

                    if (isHurtbox && createCollisionMasks)
                    {
                        sprite.CollisionMasks.Clear();
                        if (!maskNodeLookup.Any(node => node.Key.Name == sprite.Name))
                            maskNodeLookup.Add(sprite, new());
                    }

                    sprite.GMS2PlaybackSpeedType = (AnimSpeedType)playback;
                    sprite.GMS2PlaybackSpeed = animSpd;
                    sprite.IsSpecialType = isSpecial;
                    sprite.SVersion = specialVer;

                    // Update sprite dimensions
                    uint oldWidth = sprite.Width, oldHeight = sprite.Height;
                    sprite.Width = (uint)n.Texture.BoundingWidth;
                    sprite.Height = (uint)n.Texture.BoundingHeight;
                    bool changedSpriteDimensions = (oldWidth != sprite.Width || oldHeight != sprite.Height);

                    // Update origin
                    if (stripped.Contains("_palette"))
                    {
                        sprite.OriginX = 0;
                        sprite.OriginY = 0;
                    }
                    else
                    {
                        switch (offresult)
                        {
                            case ("Top Left"):
                                sprite.OriginX = 0;
                                sprite.OriginY = 0;
                                break;
                            case ("Top Center"):
                                sprite.OriginX = (int)(sprite.Width / 2);
                                sprite.OriginY = 0;
                                break;
                            case ("Top Right"):
                                sprite.OriginX = (int)(sprite.Width);
                                sprite.OriginY = 0;
                                break;
                            case ("Center Left"):
                                sprite.OriginX = 0;
                                sprite.OriginY = (int)(sprite.Height / 2);
                                break;
                            case ("Center"):
                                sprite.OriginX = (int)(sprite.Width / 2);
                                sprite.OriginY = (int)(sprite.Height / 2);
                                break;
                            case ("Center Right"):
                                sprite.OriginX = (int)(sprite.Width);
                                sprite.OriginY = (int)(sprite.Height / 2);
                                break;
                            case ("Bottom Left"):
                                sprite.OriginX = 0;
                                sprite.OriginY = (int)(sprite.Height);
                                break;
                            case ("Bottom Center"):
                                sprite.OriginX = (int)(sprite.Width / 2);
                                sprite.OriginY = (int)(sprite.Height);
                                break;
                            case ("Bottom Right"):
                                sprite.OriginX = (int)(sprite.Width);
                                sprite.OriginY = (int)(sprite.Height);
                                break;
                        }
                    }

                    // Grow bounding box depending on how much is trimmed
                    bool grewBoundingBox = false;
                    bool fullImageBbox = sprite.BBoxMode == 1;
                    bool manualBbox = sprite.BBoxMode == 2;
                    if (!manualBbox)
                    {
                        int marginLeft = fullImageBbox ? 0 : n.Texture.TargetX;
                        int marginRight = fullImageBbox ? ((int)sprite.Width - 1) : (n.Texture.TargetX + n.Bounds.Width - 1);
                        int marginTop = fullImageBbox ? 0 : n.Texture.TargetY;
                        int marginBottom = fullImageBbox ? ((int)sprite.Height - 1) : (n.Texture.TargetY + n.Bounds.Height - 1);
                        if (marginLeft < sprite.MarginLeft)
                        {
                            sprite.MarginLeft = marginLeft;
                            grewBoundingBox = true;
                        }
                        if (marginTop < sprite.MarginTop)
                        {
                            sprite.MarginTop = marginTop;
                            grewBoundingBox = true;
                        }
                        if (marginRight > sprite.MarginRight)
                        {
                            sprite.MarginRight = marginRight;
                            grewBoundingBox = true;
                        }
                        if (marginBottom > sprite.MarginBottom)
                        {
                            sprite.MarginBottom = marginBottom;
                            grewBoundingBox = true;
                        }
                    }

                    // Only generate collision masks for sprites that need them (in newer GameMaker versions)
                    if (isHurtbox && createCollisionMasks)
                    {
                        if (!maskNodeLookup[sprite].ContainsKey(frame))
                            maskNodeLookup[sprite].Add(frame, n);
                    }

                    if (frame > sprite.Textures.Count - 1)
                    {
                        while (frame > sprite.Textures.Count - 1)
                        {
                            sprite.Textures.Add(texentry);
                        }
                        continue;
                    }
                    sprite.Textures[frame] = texentry;
                }
            }
        }

        if (createCollisionMasks)
        {
            // Update masks for when bounding box masks are enabled
            foreach ((UndertaleSprite maskSpr, Dictionary<int, Node> maskNodes) in maskNodeLookup)
            {
                foreach (var (index, maskNode) in maskNodes.OrderBy(x => x.Key))
                {
                    // Generate collision mask using either bounding box or sprite dimensions
                    maskSpr.CollisionMasks.Add(maskSpr.NewMaskEntry(Data));
                    (int maskWidth, int maskHeight) = maskSpr.CalculateMaskDimensions(Data);
                    int maskStride = ((maskWidth + 7) / 8) * 8;

                    BitArray maskingBitArray = new BitArray(maskStride * maskHeight);
                    for (int y = 0; y < maskHeight && y < maskNode.Bounds.Height; y++)
                    {
                        for (int x = 0; x < maskWidth && x < maskNode.Bounds.Width; x++)
                        {
                            IMagickColor<byte> pixelColor = atlasPixels.GetPixel(x + maskNode.Bounds.X, y + maskNode.Bounds.Y).ToColor();
                            if (bboxMasks)
                            {
                                maskingBitArray[(y * maskStride) + x] = (pixelColor.A > 0);
                            }
                            else
                            {
                                maskingBitArray[((y + maskNode.Texture.TargetY) * maskStride) + x + maskNode.Texture.TargetX] = (pixelColor.A > 0);
                            }
                        }
                    }
                    BitArray tempBitArray = new BitArray(maskingBitArray.Length);
                    for (int i = 0; i < maskingBitArray.Length; i += 8)
                    {
                        for (int j = 0; j < 8; j++)
                        {
                            tempBitArray[j + i] = maskingBitArray[-(j - 7) + i];
                        }
                    }

                    int numBytes = maskingBitArray.Length / 8;
                    byte[] bytes = new byte[numBytes];
                    tempBitArray.CopyTo(bytes, 0);
                    for (int i = 0; i < bytes.Length; i++)
                        maskSpr.CollisionMasks[index].Data[i] = bytes[i];
                }

                maskNodes.Clear();
            }
        }

        maskNodeLookup.Clear();

        // Increment atlas
        atlasCount++;
    }

    HideProgressBar();
}
finally
{
    foreach (MagickImage img in imagesToCleanup)
    {
        img.Dispose();
    }
}

// --- Begin Imports from ImportGraphicsAdvanced.csx ---

public class TextureInfo
{
    public string Source;
    public int Width;
    public int Height;
    public int TargetX;
    public int TargetY;
    public int BoundingWidth;
    public int BoundingHeight;
    public MagickImage Image;
}

public enum SpriteType
{
    Sprite,
    Background,
    Font,
    Unknown
}

public enum SplitType
{
    Horizontal,
    Vertical,
}

public enum BestFitHeuristic
{
    Area,
    MaxOneAxis,
}

public struct Rect
{
    public int X { get; set; }
    public int Y { get; set; }
    public int Width { get; set; }
    public int Height { get; set; }
}

public class Node
{
    public Rect Bounds;
    public TextureInfo Texture;
    public SplitType SplitType;
}

public class Atlas
{
    public int Width;
    public int Height;
    public List<Node> Nodes;
}

public class Packer
{
    public List<TextureInfo> SourceTextures;
    public StringWriter Log;
    public StringWriter Error;
    public int Padding;
    public int AtlasSize;
    public bool DebugMode;
    public BestFitHeuristic FitHeuristic;
    public List<Atlas> Atlasses;
    public HashSet<string> Sources;

    public Packer()
    {
        SourceTextures = new List<TextureInfo>();
        Log = new StringWriter();
        Error = new StringWriter();
    }

    public void Process(string _SourceDir, int _AtlasSize, int _Padding, bool _DebugMode)
    {
        Padding = _Padding;
        AtlasSize = _AtlasSize;
        DebugMode = _DebugMode;
        //1: scan for all the textures we need to pack
        Sources = new HashSet<string>();
        ScanForTextures(_SourceDir);
        List<TextureInfo> textures = new List<TextureInfo>();
        textures = SourceTextures.ToList();
        //2: generate as many atlasses as needed (with the latest one as small as possible)
        Atlasses = new List<Atlas>();
        while (textures.Count > 0)
        {
            Atlas atlas = new Atlas();
            atlas.Width = _AtlasSize;
            atlas.Height = _AtlasSize;
            List<TextureInfo> leftovers = LayoutAtlas(textures, atlas);
            if (leftovers.Count == 0)
            {
                // we reached the last atlas. Check if this last atlas could have been twice smaller
                while (leftovers.Count == 0)
                {
                    atlas.Width /= 2;
                    atlas.Height /= 2;
                    leftovers = LayoutAtlas(textures, atlas);
                }
                // we need to go 1 step larger as we found the first size that is too small
                // if the atlas is 0x0 then it should be 1x1 instead
                if (atlas.Width == 0)
                {
                    atlas.Width = 1;
                }
                else
                {
                    atlas.Width *= 2;
                }
                if (atlas.Height == 0)
                {
                    atlas.Height = 1;
                }
                else
                {
                    atlas.Height *= 2;
                }
                leftovers = LayoutAtlas(textures, atlas);
            }
            Atlasses.Add(atlas);
            textures = leftovers;
        }
    }

    public void SaveAtlasses(string _Destination)
    {
        int atlasCount = 0;
        string prefix = _Destination.Replace(Path.GetExtension(_Destination), "");
        string descFile = _Destination;
        StreamWriter tw = new StreamWriter(_Destination);
        tw.WriteLine("source_tex, atlas_tex, x, y, width, height");
        foreach (Atlas atlas in Atlasses)
        {
            string atlasName = $"{prefix}{atlasCount:000}.png";

            // 1: Save images
            using (MagickImage img = CreateAtlasImage(atlas))
                TextureWorker.SaveImageToFile(img, atlasName);

            // 2: save description in file
            foreach (Node n in atlas.Nodes)
            {
                if (n.Texture != null)
                {
                    tw.Write(n.Texture.Source + ", ");
                    tw.Write(atlasName + ", ");
                    tw.Write((n.Bounds.X).ToString() + ", ");
                    tw.Write((n.Bounds.Y).ToString() + ", ");
                    tw.Write((n.Bounds.Width).ToString() + ", ");
                    tw.WriteLine((n.Bounds.Height).ToString());
                }
            }
            ++atlasCount;
        }
        tw.Close();
        tw = new StreamWriter(prefix + ".log");
        tw.WriteLine("--- LOG -------------------------------------------");
        tw.WriteLine(Log.ToString());
        tw.WriteLine("--- ERROR -----------------------------------------");
        tw.WriteLine(Error.ToString());
        tw.Close();
    }

    private void ScanForTextures(string _Path)
    {
        DirectoryInfo di = new DirectoryInfo(_Path);
        FileInfo[] files = di.GetFiles("*", SearchOption.AllDirectories);
        foreach (FileInfo fi in files)
        {
            SpriteType spriteType = GetSpriteType(fi.FullName);
            string ext = Path.GetExtension(fi.FullName);

            bool isSprite = spriteType == SpriteType.Sprite || (spriteType == SpriteType.Unknown && importAsSprite);

            if (ext == ".gif")
            {
                // animated .gif
                string dirName = Path.GetDirectoryName(fi.FullName);
                string spriteName = Path.GetFileNameWithoutExtension(fi.FullName);

                MagickReadSettings settings = new()
                {
                    ColorSpace = ColorSpace.sRGB,
                };
                using MagickImageCollection gif = new(fi.FullName, settings);
                int frames = gif.Count;
                if (!isSprite && frames > 1)
                {
                    throw new ScriptException(fi.FullName + " is a " + spriteType + ", but has more than 1 frame. Script has been stopped.");
                }

                for (int i = frames - 1; i >= 0; i--)
                {
                    AddSource(
                        (MagickImage)gif[i],
                        Path.Join(
                            dirName,
                            isSprite ?
                                (spriteName + "_" + i + ".png") : (spriteName + ".png")
                        )
                    );
                    // don't auto-dispose
                    gif.RemoveAt(i);
                }
            }
            else if (ext == ".png")
            {
                Match stripMatch = null;
                if (isSprite)
                {
                    stripMatch = Regex.Match(Path.GetFileNameWithoutExtension(fi.Name), @"(.*)_strip(\d+)");
                }
                if (stripMatch is not null && stripMatch.Success)
                {
                    string spriteName = stripMatch.Groups[1].Value;
                    string frameCountStr = stripMatch.Groups[2].Value;

                    uint frames;
                    try
                    {
                        frames = UInt32.Parse(frameCountStr);
                    }
                    catch
                    {
                        throw new ScriptException(fi.FullName + " has an invalid strip numbering scheme. Script has been stopped.");
                    }
                    if (frames <= 0)
                    {
                        throw new ScriptException(fi.FullName + " has 0 frames. Script has been stopped.");
                    }

                    if (!isSprite && frames > 1)
                    {
                        throw new ScriptException(fi.FullName + " is not a sprite, but has more than 1 frame. Script has been stopped.");
                    }

                    MagickReadSettings settings = new()
                    {
                        ColorSpace = ColorSpace.sRGB,
                    };
                    using MagickImage img = new(fi.FullName, settings);
                    if ((img.Width % frames) > 0)
                    {
                        throw new ScriptException(fi.FullName + " has a width not divisible by the number of frames. Script has been stopped.");
                    }

                    string dirName = Path.GetDirectoryName(fi.FullName);

                    uint frameWidth = (uint)img.Width / frames;
                    uint frameHeight = (uint)img.Height;
                    for (uint i = 0; i < frames; i++)
                    {
                        AddSource(
                            (MagickImage)img.Clone(
                                (int)(frameWidth * i), 0, frameWidth, frameHeight
                            ),
                            Path.Join(dirName,
                                isSprite ?
                                    (spriteName + "_" + i + ".png") : (spriteName + ".png")
                            )
                        );
                    }
                }
                else
                {
                    MagickReadSettings settings = new()
                    {
                        ColorSpace = ColorSpace.sRGB,
                    };
                    MagickImage img = new(fi.FullName);
                    AddSource(img, fi.FullName);
                }
            }
        }
    }

    private void AddSource(MagickImage img, string fullName)
    {
        imagesToCleanup.Add(img);
        if (img.Width <= AtlasSize && img.Height <= AtlasSize)
        {
            TextureInfo ti = new TextureInfo();

            if (!Sources.Add(fullName))
            {
                throw new ScriptException(
                    Path.GetFileNameWithoutExtension(fullName) +
                    " as a frame already exists (possibly due to having multiple types of sprite images named the same). Script has been stopped."
                );
            }

            ti.Source = fullName;
            ti.BoundingWidth = (int)img.Width;
            ti.BoundingHeight = (int)img.Height;

            // GameMaker doesn't trim tilesets. I assume it didn't trim backgrounds too
            ti.TargetX = 0;
            ti.TargetY = 0;
            if (GetSpriteType(ti.Source) != SpriteType.Background)
            {
                img.BorderColor = MagickColors.Transparent;
                img.BackgroundColor = MagickColors.Transparent;
                img.Border(1);
                IMagickGeometry? bbox = img.BoundingBox;
                if (bbox is not null)
                {
                    ti.TargetX = bbox.X - 1;
                    ti.TargetY = bbox.Y - 1;
                    img.Trim();
                }
                else
                {
                    ti.TargetX = 0;
                    ti.TargetY = 0;
                    img.Crop(1, 1);
                }
                img.ResetPage();
            }
            ti.Width = (int)img.Width;
            ti.Height = (int)img.Height;
            ti.Image = img;

            SourceTextures.Add(ti);

            Log.WriteLine("Added " + fullName);
        }
        else
        {
            Error.WriteLine(fullName + " is too large to fix in the atlas. Skipping!");
        }
    }

    private void HorizontalSplit(Node _ToSplit, int _Width, int _Height, List<Node> _List)
    {
        Node n1 = new Node();
        n1.Bounds.X = _ToSplit.Bounds.X + _Width + Padding;
        n1.Bounds.Y = _ToSplit.Bounds.Y;
        n1.Bounds.Width = _ToSplit.Bounds.Width - _Width - Padding;
        n1.Bounds.Height = _Height;
        n1.SplitType = SplitType.Vertical;
        Node n2 = new Node();
        n2.Bounds.X = _ToSplit.Bounds.X;
        n2.Bounds.Y = _ToSplit.Bounds.Y + _Height + Padding;
        n2.Bounds.Width = _ToSplit.Bounds.Width;
        n2.Bounds.Height = _ToSplit.Bounds.Height - _Height - Padding;
        n2.SplitType = SplitType.Horizontal;
        if (n1.Bounds.Width > 0 && n1.Bounds.Height > 0)
            _List.Add(n1);
        if (n2.Bounds.Width > 0 && n2.Bounds.Height > 0)
            _List.Add(n2);
    }

    private void VerticalSplit(Node _ToSplit, int _Width, int _Height, List<Node> _List)
    {
        Node n1 = new Node();
        n1.Bounds.X = _ToSplit.Bounds.X + _Width + Padding;
        n1.Bounds.Y = _ToSplit.Bounds.Y;
        n1.Bounds.Width = _ToSplit.Bounds.Width - _Width - Padding;
        n1.Bounds.Height = _ToSplit.Bounds.Height;
        n1.SplitType = SplitType.Vertical;
        Node n2 = new Node();
        n2.Bounds.X = _ToSplit.Bounds.X;
        n2.Bounds.Y = _ToSplit.Bounds.Y + _Height + Padding;
        n2.Bounds.Width = _Width;
        n2.Bounds.Height = _ToSplit.Bounds.Height - _Height - Padding;
        n2.SplitType = SplitType.Horizontal;
        if (n1.Bounds.Width > 0 && n1.Bounds.Height > 0)
            _List.Add(n1);
        if (n2.Bounds.Width > 0 && n2.Bounds.Height > 0)
            _List.Add(n2);
    }

    private TextureInfo FindBestFitForNode(Node _Node, List<TextureInfo> _Textures)
    {
        TextureInfo bestFit = null;
        float nodeArea = _Node.Bounds.Width * _Node.Bounds.Height;
        float maxCriteria = 0.0f;
        foreach (TextureInfo ti in _Textures)
        {
            switch (FitHeuristic)
            {
                case BestFitHeuristic.MaxOneAxis:
                    if (ti.Width <= _Node.Bounds.Width && ti.Height <= _Node.Bounds.Height)
                    {
                        float wRatio = (float)ti.Width / (float)_Node.Bounds.Width;
                        float hRatio = (float)ti.Height / (float)_Node.Bounds.Height;
                        float ratio = wRatio > hRatio ? wRatio : hRatio;
                        if (ratio > maxCriteria)
                        {
                            maxCriteria = ratio;
                            bestFit = ti;
                        }
                    }
                    break;
                case BestFitHeuristic.Area:
                    if (ti.Width <= _Node.Bounds.Width && ti.Height <= _Node.Bounds.Height)
                    {
                        float textureArea = ti.Width * ti.Height;
                        float coverage = textureArea / nodeArea;
                        if (coverage > maxCriteria)
                        {
                            maxCriteria = coverage;
                            bestFit = ti;
                        }
                    }
                    break;
            }
        }
        return bestFit;
    }

    private List<TextureInfo> LayoutAtlas(List<TextureInfo> _Textures, Atlas _Atlas)
    {
        List<Node> freeList = new List<Node>();
        List<TextureInfo> textures = new List<TextureInfo>();
        _Atlas.Nodes = new List<Node>();
        textures = _Textures.ToList();
        Node root = new Node();
        root.Bounds.Width = _Atlas.Width;
        root.Bounds.Height = _Atlas.Height;
        root.SplitType = SplitType.Horizontal;
        freeList.Add(root);
        while (freeList.Count > 0 && textures.Count > 0)
        {
            Node node = freeList[0];
            freeList.RemoveAt(0);
            TextureInfo bestFit = FindBestFitForNode(node, textures);
            if (bestFit != null)
            {
                if (node.SplitType == SplitType.Horizontal)
                {
                    HorizontalSplit(node, bestFit.Width, bestFit.Height, freeList);
                }
                else
                {
                    VerticalSplit(node, bestFit.Width, bestFit.Height, freeList);
                }
                node.Texture = bestFit;
                node.Bounds.Width = bestFit.Width;
                node.Bounds.Height = bestFit.Height;
                textures.Remove(bestFit);
            }
            _Atlas.Nodes.Add(node);
        }
        return textures;
    }

    private MagickImage CreateAtlasImage(Atlas _Atlas)
    {
        MagickImage img = new(MagickColors.Transparent, (uint)_Atlas.Width, (uint)_Atlas.Height);
        foreach (Node n in _Atlas.Nodes)
        {
            if (n.Texture is not null)
            {
                using IMagickImage<byte> resizedSourceImg = TextureWorker.ResizeImage(n.Texture.Image, n.Bounds.Width, n.Bounds.Height);
                img.Composite(resizedSourceImg, n.Bounds.X, n.Bounds.Y, CompositeOperator.Copy);
            }
        }
        return img;
    }
}

// --- End Imports from ImportGraphicsAdvanced.csx ---

// --- OffsetResult and GetSpriteType helpers ---
public static SpriteType GetSpriteType(string path)
{
    string folderPath = Path.GetDirectoryName(path);
    string folderName = new DirectoryInfo(folderPath).Name;
    string lowerName = folderName.ToLower();

    if (lowerName == "backgrounds" || lowerName == "background")
    {
        return SpriteType.Background;
    }
    else if (lowerName == "fonts" || lowerName == "font")
    {
        return SpriteType.Font;
    }
    else if (lowerName == "sprites" || lowerName == "sprite")
    {
        return SpriteType.Sprite;
    }
    return SpriteType.Unknown;
}

// No user dialog: set all options to default values (on/enabled)
public void OffsetResult()
{
    isSpecial = true;
    specialVer = 1;
    animSpd = 1;
    offresult = "Center";
    playback = 0;
    createCollisionMasks = true;
}

// --- 3. Generate and Import gml_GlobalScript_character_data ---
UpdateProgress("Generating gml_GlobalScript_character_data..."); // Update progress for GML script generation

// 1. Find all JSON files in the import folder (including subfolders) that contain '_data' in the filename
string[] jsonFiles = Directory.GetFiles(importFolder, "*_data*.json", SearchOption.AllDirectories);

// 2. Start building the GML script content
string gmlScriptName = "gml_GlobalScript_character_data";
string gmlFileName = gmlScriptName + ".gml";
string gmlScriptPath = Path.Combine(importFolder, gmlFileName);


var gmlBuilder = new System.Text.StringBuilder();
var dataEntries = new List<string> {
    "character_define(\"eureka\", anim_timings_eureka, character_init_eureka, 213, 494, 881, 427, 31, 1444, 549, 1514, 44, 248, 541, 804, 523, [\"texture_gameplay_eureka\"], cpu_script_eureka)",
    "character_define(\"knockt\", anim_timings_knockt, character_init_knockt, 178, 670, 71, 212, 242, 1270, 1217, 1025, 439, 45, 619, 1548, 721, [\"texture_gameplay_knockt\"], cpu_script_knockt)",
    "character_define(\"rend\", anim_timings_rend, character_init_rend, 437, 850, 1239, 1311, 76, 386, 554, 750, 358, 184, 550, 816, 1415, [\"texture_gameplay_rend\"], cpu_script_rend)",
    "character_define(\"Random\", anim_timings_rend, character_init_rend, 437, 850, 1239, 1311, 199, 386, 554, 750, 358, 184, 550, 816, 1415, [\"texture_gameplay_rend\"], cpu_script_rend)"
};
gmlBuilder.AppendLine("function character_data_get_all()");
gmlBuilder.AppendLine("{");

// Add all JSON contents
foreach (var jsonFile in jsonFiles)
{
    string jsonContent = File.ReadAllText(jsonFile).Trim();
    if (!string.IsNullOrWhiteSpace(jsonContent))
    {
        dataEntries.Add(jsonContent);
    }
}
gmlBuilder.AppendLine($"    static _data = [{string.Join(", ", dataEntries)}];");
gmlBuilder.AppendLine("    return _data;");
gmlBuilder.AppendLine("}");

// 5. Write the new GML file to the import folder
File.WriteAllText(gmlScriptPath, gmlBuilder.ToString());

// 6. Import the new GML script into UMT
// (This uses the same import logic as the other GML files)
string code = File.ReadAllText(gmlScriptPath);
SyncBinding("Strings, Code, CodeLocals, Scripts, GlobalInitScripts, GameObjects, Functions, Variables", true);
await Task.Run(() =>
{
    CodeImportGroup importGroup = new(Data)
    {
        AutoCreateAssets = true
    };
    importGroup.QueueReplace(gmlScriptName, code);
    importGroup.Import();
});
DisableAllSyncBindings();

// --- 4. Generate and Import gml_Object_obj_css_portraits_list_Create_0 ---
UpdateProgress("Generating gml_Object_obj_css_portraits_list_Create_0..."); // Update progress for portraits list generation

// 1. Find all JSON files in the import folder (including subfolders) that contain '_portrait' in the filename
string[] portraitJsonFiles = Directory.GetFiles(importFolder, "*_portrait*.json", SearchOption.AllDirectories);

string portraitScriptName = "gml_Object_obj_css_portraits_list_Create_0";
string portraitFileName = portraitScriptName + ".gml";
string portraitScriptPath = Path.Combine(importFolder, portraitFileName);


var portraitBuilder = new System.Text.StringBuilder();
// Start with the hardcoded characters
var validCharactersList = new List<string> { "\"eureka\"", "\"knockt\"", "\"rend\"" };
// Add all JSON contents
foreach (var jsonFile in portraitJsonFiles)
{
    string jsonContent = File.ReadAllText(jsonFile).Trim();
    if (!string.IsNullOrWhiteSpace(jsonContent))
    {
        validCharactersList.Add(jsonContent);
    }
}
portraitBuilder.Append("validCharacters = [");
portraitBuilder.Append(string.Join(", ", validCharactersList));
portraitBuilder.AppendLine("];");
portraitBuilder.AppendLine(@"charactersPerRow = 4;
spacing_x = 40;
spacing_y = 0;
portraitObjects = [];
portraitsCreated = false;
function createPortraits()
{
    var max_width = sprite_width;
    var max_height = sprite_height;
    var p_width_default = sprite_get_width(spr_css_portrait_eureka);
    var p_height_default = sprite_get_height(spr_css_portrait_eureka);
    var p_scale = min(max_width / p_width_default, max_height / p_height_default, 1);
    var p_width = p_width_default * p_scale;
    var p_height = p_height_default * p_scale;
    var validCharIds = [];
    
    for (var i = 0; i < array_length(validCharacters); i++)
    {
        for (var j = 0; j < character_count(); j++)
        {
            if (character_data_get(j, UnknownEnum.Value_0) == validCharacters[i])
            {
                array_insert(validCharIds, min(array_length(validCharIds), i), j);
                break;
            }
        }
    }
    
    var rowChars = 0;
    var rowNumber = 0;
    var xx = 0;
    var yy = max_height / ((array_length(validCharacters) / charactersPerRow) * 2);
    var remainingCharacters = array_length(validCharIds);
    
    for (var c = 0; c < array_length(validCharIds); c++)
    {
        if ((rowChars % charactersPerRow) == 0)
        {
            rowNumber += 1;
            xx = 0;
            
            if ((array_length(validCharIds) % 2) != 0)
                xx += (p_width / 2);
            
            xx += ((min(remainingCharacters, charactersPerRow) / 2) * (p_width + spacing_x));
            
            if (rowChars != 0)
                yy += (p_height * 0.95);
        }
        
        var newPortrait = instance_create_layer(xx + x, yy + y, layer, obj_css_portrait);
        var characterName = character_data_get(validCharIds[c], UnknownEnum.Value_0);
        array_push(portraitObjects, newPortrait);
        
        if (characterName == validCharacters[0])
            global.cpuDefaultPortrait = newPortrait;
        
        newPortrait.character = characterName;
        newPortrait.sprite = character_data_get(validCharIds[c], UnknownEnum.Value_2);
        newPortrait.defaultScale = p_scale;
        
        if (room == rm_css)
        {
            var data = engine().css_player_data;
            
            if (array_length(data) != 0)
            {
                if (array_length(global.cssPortraits) != 0)
                {
                    for (var i = 0; i < array_length(data); i++)
                    {
                        var p = obj_css.players[i];
                        
                        if (global.cssPortraits != [])
                        {
                            if (global.cssPortraits[i] == newPortrait.character)
                            {
                                p.hoveredPortrait = newPortrait;
                                p.hoveredPortrait.hovered++;
                            }
                        }
                    }
                }
            }
        }
        
        xx += (spacing_x + p_width);
        rowChars += 1;
        remainingCharacters -= 1;
    }
    
    portraitsCreated = true;
}

enum UnknownEnum
{
    Value_0,
    Value_2 = 2
}");


// Write the new GML file to the import folder
File.WriteAllText(portraitScriptPath, portraitBuilder.ToString());

// Import the new GML script into UMT
string portraitCode = File.ReadAllText(portraitScriptPath);
SyncBinding("Strings, Code, CodeLocals, Scripts, GlobalInitScripts, GameObjects, Functions, Variables", true);
await Task.Run(() =>
{
    CodeImportGroup importGroup = new(Data)
    {
        AutoCreateAssets = true
    };
    importGroup.QueueReplace(portraitScriptName, portraitCode);
    importGroup.Import();
});
DisableAllSyncBindings();

// --- 1. Import GML Scripts (from all subfolders) ---
UpdateProgress("Importing all GML scripts..."); // Update progress for GML scripts import
string[] gmlFiles = Directory.GetFiles(importFolder, "*.gml", SearchOption.AllDirectories);
if (gmlFiles.Length > 0)
{
    bool doLink = true;
    SetProgressBar(null, "Importing GML Scripts", 0, gmlFiles.Length);
    StartProgressBarUpdater();

    SyncBinding("Strings, Code, CodeLocals, Scripts, GlobalInitScripts, GameObjects, Functions, Variables", true);
    await Task.Run(() =>
    {
        CodeImportGroup importGroup = new(Data)
        {
            AutoCreateAssets = doLink
        };
        foreach (string file in gmlFiles)
        {
            IncrementProgress();
            string code = File.ReadAllText(file);
            string baseCodeName = Path.GetFileNameWithoutExtension(file);
            importGroup.QueueReplace(baseCodeName, code);
        }
        SetProgressBar(null, "Performing final import...", gmlFiles.Length, gmlFiles.Length);
        importGroup.Import();
    });
    DisableAllSyncBindings();

    await StopProgressBarUpdater();
    HideProgressBar(); // Hide the progress bar after completion
    progressForm.Close(); // Close the progress form
//    ScriptMessage("All GML scripts successfully imported.");
}
else
{
    ScriptMessage("No GML scripts found to import.");
}

