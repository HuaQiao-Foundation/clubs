# Georgetown Rotary - Image & Asset Management Guide

## For Club Officers & Content Administrators

This guide explains how to manage images and assets in the Georgetown Rotary Speaker Management system using our professional organization structure.

## Professional Asset Organization

### Asset Folder Structure
```
public/
├── assets/
│   ├── images/
│   │   ├── logos/          # Official Rotary logos
│   │   ├── icons/          # Favicons and app icons
│   │   └── backgrounds/    # Background images
│   ├── fonts/              # Custom fonts
│   └── documents/          # PDFs, guides, etc.
├── favicon.svg             # Main adaptive favicon
└── manifest.json          # PWA configuration
```

### When to Use Each Folder

**`/public/assets/images/logos/`** - Official logos
- Rotary International logos
- Georgetown Rotary Club branding
- Partner organization logos

**`/public/assets/images/icons/`** - App icons and favicons
- Favicon files (PNG format)
- PWA app icons
- System icons

**`/public/assets/images/backgrounds/`** - Background images
- Header backgrounds
- Section backgrounds
- Pattern images

**`/public/assets/fonts/`** - Typography
- Open Sans font files
- Custom web fonts

## Image Optimization Features

### Automatic Optimization
- **All images are automatically optimized** during the build process
- Images are compressed to reduce file sizes without visible quality loss
- Mobile devices load smaller versions automatically
- Lazy loading prevents images from slowing down initial page load

### Supported Image Formats
- **PNG** - Best for logos, graphics with transparency
- **JPG/JPEG** - Best for photographs
- **SVG** - Best for logos and icons (scalable without quality loss)
- **WebP** - Modern format with better compression (automatically generated)

## How to Add/Update Images

### 1. Adding Images to the System
1. **Choose the correct folder** based on image type (see structure above)
2. Place image files in the appropriate `/public/assets/` subfolder
3. Use descriptive filenames (e.g., `speaker-john-doe.jpg`, `event-2025-gala.png`)
4. Images are automatically optimized when the site builds

### 2. Image Size Guidelines
- **Speaker photos**: Maximum 800x800 pixels
- **Event banners**: Maximum 1920x600 pixels
- **Logos**: Use SVG format when possible, or PNG with transparent background
- **General images**: Keep under 2MB before optimization

### 3. Professional File Naming
- **Use lowercase only**: `georgetown-rotary-logo.svg`
- **Hyphens for spaces**: `rotary-members-2025.jpg`
- **Descriptive names**: `speaker-photo-jane-smith.jpg`
- **Version dates**: `annual-report-2025-v2.pdf`

## Using the Responsive Image Component

When adding images to the application, use the ResponsiveImage component for optimal performance:

```jsx
import ResponsiveImage from './components/ResponsiveImage';

<ResponsiveImage
  src="/assets/images/logos/rotary-logo.svg"
  alt="Description of image"
  priority={true}  // Use for above-the-fold images
/>
```

### 4. Referencing Images in Code
Always use the full organized path when referencing images:

**✅ Correct:**
```html
<img src="/assets/images/logos/RotaryMBS-Simple_REV.svg" alt="Rotary Logo" />
```

**❌ Incorrect:**
```html
<img src="/RotaryMBS-Simple_REV.svg" alt="Rotary Logo" />
```

## Brand Asset Protection

⚠️ **See [rotary-brand-guide.md](rotary-brand-guide.md) for complete brand asset protection requirements**

**Quick Reference**:
- NEVER modify official Rotary logos
- Use original files exactly as provided
- Contact CEO before any brand asset changes

## Favicon Management

### Current Favicon Setup
The site uses the **official Rotary Mark of Excellence logo** as the favicon with:
- **Light mode**: Original Azure blue (#1873c3) Rotary Mark of Excellence
- **Dark mode**: Original white/reverse Rotary Mark of Excellence (automatic switching)
- **Brand compliance**: Uses EXACT content from official Rotary logo files
- **Progressive enhancement**: Falls back to PNG icons for older browsers

### Authentic Rotary Implementation
- **Official assets**: Uses RotaryMoE-R_Azure-CMYK-C.svg and RotaryMoE-R_REV.svg
- **Trademark compliant**: No modifications to original logo designs
- **Professional quality**: Worthy of Rotary International standards
- **Legal protection**: Maintains Georgetown Rotary's usage rights

### Updating Favicon
1. **NEVER** modify files in `/public/assets/images/logos/`
2. Get CEO approval before any brand asset changes
3. Use original assets by COMBINING, not modifying them
4. Test final output against original files for accuracy
5. See [rotary-brand-guide.md](rotary-brand-guide.md) for complete brand asset requirements

## Performance Monitoring

### Checking Image Performance
1. Open Chrome DevTools (F12)
2. Go to Network tab
3. Filter by "Img" to see all images
4. Look for:
   - Load times (should be under 1 second on mobile)
   - File sizes (optimized images show reduced sizes)
   - Priority (LCP images should load first)

### Mobile Testing
1. Use Chrome DevTools Device Mode
2. Select mobile device (e.g., iPhone, Pixel)
3. Check that images load quickly and display correctly
4. Verify touch targets are at least 44x44 pixels

## Troubleshooting

### Image Not Appearing
- Check filename spelling and case sensitivity
- Verify file is in `/public` folder
- Ensure proper file extension (.jpg, .png, .svg)

### Slow Loading on Mobile
- Reduce original image dimensions
- Use JPG instead of PNG for photos
- Enable priority loading for important images

### Favicon Not Showing
- Clear browser cache
- Check that favicon files exist in `/public`
- Verify HTML meta tags in index.html

## Technical Details

### Optimization Settings
- PNG: 80% quality
- JPG: 75% quality
- WebP: 80% quality
- AVIF: 70% quality

### Build Process
Images are optimized during `npm run build` using:
- **Sharp.js** for image processing
- **SVGO** for SVG optimization
- **Vite** for bundling and serving

## Support

For technical assistance with image management:
1. Check this guide first
2. Test on different devices/browsers
3. Contact your technical administrator
4. Report issues with specific image filenames and error messages

---

*Last updated: September 2025*
*Georgetown Rotary Club - Speaker Management System*