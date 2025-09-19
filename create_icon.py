#!/usr/bin/env python3

import os
from PIL import Image, ImageDraw, ImageFont
import json

def create_app_icon():
    """Create a simple gradient app icon with 'R' letter"""
    
    # Create 1024x1024 image with gradient
    size = 1024
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Create aurora gradient background
    for y in range(size):
        # Gradient from purple to blue
        progress = y / size
        r = int(100 * (1 - progress) + 40 * progress)
        g = int(50 * (1 - progress) + 100 * progress)
        b = int(255 * (1 - progress) + 255 * progress)
        draw.rectangle([(0, y), (size, y+1)], fill=(r, g, b, 255))
    
    # Add subtle radial gradient overlay
    for i in range(size//4, 0, -1):
        alpha = int(255 * (1 - i/(size//4)) * 0.3)
        color = (255, 255, 255, alpha)
        draw.ellipse(
            [(size//2 - i, size//2 - i), (size//2 + i, size//2 + i)],
            fill=None,
            outline=color,
            width=2
        )
    
    # Draw "R" letter in center
    try:
        # Try to use a system font
        font_size = size // 2
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", font_size)
    except:
        # Fallback to default font
        font = ImageFont.load_default()
    
    text = "R"
    # Get text bbox
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    # Center the text
    x = (size - text_width) // 2
    y = (size - text_height) // 2 - text_height // 10
    
    # Draw text with glow effect
    for offset in range(10, 0, -1):
        alpha = int(255 * (1 - offset/10) * 0.5)
        draw.text((x, y), text, font=font, fill=(255, 255, 255, alpha))
    
    # Draw main text
    draw.text((x, y), text, font=font, fill=(255, 255, 255, 255))
    
    # Save the icon
    icon_path = "/Users/alisimacpro/Desktop/RayLink/RayLink/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
    img.save(icon_path, "PNG")
    print(f"✅ Created app icon: {icon_path}")
    
    # Update Contents.json to reference the icon
    contents_path = "/Users/alisimacpro/Desktop/RayLink/RayLink/Assets.xcassets/AppIcon.appiconset/Contents.json"
    contents = {
        "images": [
            {
                "filename": "AppIcon.png",
                "idiom": "universal",
                "platform": "ios",
                "size": "1024x1024"
            }
        ],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }
    
    with open(contents_path, 'w') as f:
        json.dump(contents, f, indent=2)
    print(f"✅ Updated Contents.json")

if __name__ == "__main__":
    try:
        from PIL import Image, ImageDraw, ImageFont
        create_app_icon()
    except ImportError:
        print("⚠️  PIL not installed. Using fallback method...")
        # Create a simple 1x1 PNG as placeholder
        import base64
        
        # 1x1 blue PNG
        png_data = base64.b64decode(
            b'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='
        )
        
        icon_path = "/Users/alisimacpro/Desktop/RayLink/RayLink/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
        with open(icon_path, 'wb') as f:
            f.write(png_data)
        print("✅ Created placeholder app icon")