# Live Preview Implementation for Website Editor

## Overview
This implementation adds real-time preview updates for **text**, **textarea (WYSIWYG)**, and **image** fields in the website editor's single field sidebar. Previously, only style changes were previewed in real-time.

## What Was Changed

### 1. JavaScript - `app/javascript/editor.js`

#### Added New Function: `initializeLiveContentUpdates()`
This function handles live preview updates for content fields (text, textarea, images).

**Key Features:**
- **Text Fields**: Updates preview in real-time as you type
- **WYSIWYG Fields**: Updates preview when using the rich text editor (Quill)
- **Image Fields**: Shows image preview immediately when file is selected
- **Visual Feedback**: Adds a brief highlight animation when content updates

**How it works:**
1. Gets the current field class pattern: `{theme_page_id}_{component_page_id}_{field_name}`
2. Finds all matching elements in the preview using attribute selectors
3. Attaches event listeners to form fields
4. Updates preview elements when form values change

#### Updated Function: `updateSidebarContent()`
Added initialization of `initializeLiveContentUpdates()` when the single field sidebar loads:

```javascript
if (data.html && data.html.includes('single-field-form')) {
    setTimeout(() => {
        initializeLiveStyleUpdates();
        initializeLiveContentUpdates(); // NEW
    }, 100);
}
```

#### Updated Function: `initializeLiveStyleUpdates()`
Added support for image style properties:
- `height`: Image height in pixels
- `object_fit`: How images should fit their container (cover/contain)

### 2. WYSIWYG Controller - `app/javascript/controllers/wysiwyg_controller.js`

**Changes:**
1. **Stored Quill instance** on the editor element for external access:
   ```javascript
   this.editorTarget.__quill = this.quill
   ```

2. **Dispatches input event** when content changes:
   ```javascript
   this.quill.on('text-change', () => {
       this.inputTarget.value = this.quill.root.innerHTML
       this.inputTarget.dispatchEvent(new Event('input', { bubbles: true }))
   })
   ```

This allows the live preview system to detect WYSIWYG changes.

## How It Works

### Text Fields
When you type in a text field:
1. Input event fires
2. `initializeLiveContentUpdates()` captures the new value
3. Finds all preview elements with matching class
4. Updates `textContent` of preview elements
5. Adds visual feedback animation

### WYSIWYG/Textarea Fields
When you edit rich text:
1. Quill editor detects text change
2. Updates hidden input field
3. Dispatches input event
4. Live preview system captures the change
5. Updates `innerHTML` of preview elements
6. Adds visual feedback animation

**Fallback:** If Quill instance isn't accessible, uses MutationObserver to watch the hidden input field.

### Image Fields
When you select an image:
1. File input change event fires
2. FileReader reads the file as Data URL
3. Updates preview elements:
   - For `<img>` tags: Updates `src` attribute
   - For other elements: Sets as `background-image`
4. Adds visual feedback animation

## Field Class Pattern

The system uses a specific class naming pattern to match form fields with preview elements:

**Form Field Class:**
```
field_{theme_page_id}_{component_page_id}_{field_name}
```

**Preview Element Class:**
```
{theme_page_id}_{component_page_id}_{field_name}
```

**Example:**
- Theme Page ID: `a1b2c3d4-e5f6-7890-abcd-ef1234567890`
- Component Page ID: `b2c3d4e5-f6a7-8901-bcde-f12345678901`
- Field Name: `title`

Form field class:
```
field_a1b2c3d4-e5f6-7890-abcd-ef1234567890_b2c3d4e5-f6a7-8901-bcde-f12345678901_title
```

Preview element class:
```
a1b2c3d4-e5f6-7890-abcd-ef1234567890_b2c3d4e5-f6a7-8901-bcde-f12345678901_title
```

## Visual Feedback

When content updates, elements briefly show a visual highlight:

```css
.field-updated {
    transition: all 0.3s ease !important;
    background-color: rgba(59, 130, 246, 0.1) !important;
    border-color: #3b82f6 !important;
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1) !important;
}
```

This CSS is already defined in the existing `editor.js` file.

## Component Example

Using your example component:

### HTML Template:
```html
<h2 class="mb-0 {{title_class}} editable-field">{{title}}</h2>
<img class="{{image_class}} editable-field" src="{{image}}" alt="">
```

### After Rendering:
```html
<h2 class="mb-0 a1b2c3d4-..._title editable-field" onclick="showEditorFields('a1b2c3d4-..._title')">
    Proven expertise in SEO & digital marketing
</h2>
<img class="a1b2c3d4-..._image editable-field" 
     src="/rails/active_storage/blobs/..." 
     alt=""
     onclick="showEditorFields('a1b2c3d4-..._image')">
```

### When Editing:
1. Click on the title → Opens single field sidebar
2. Type new text → Preview updates immediately
3. Click on the image → Opens single field sidebar
4. Select new image → Preview shows new image immediately

## Browser Compatibility

The implementation uses modern JavaScript features:
- `querySelector` / `querySelectorAll`
- `FileReader` API
- `MutationObserver` API
- Arrow functions
- Template literals

All are supported in modern browsers (Chrome, Firefox, Safari, Edge).

## Debugging

Console logs are included for debugging:
- `Initializing live content updates...`
- `Found {n} target elements for class: {class}`
- `Updated {n} elements with text: {value}`
- `Updated {n} elements with WYSIWYG content`
- `Updated {n} elements with new image`

Check the browser console if live preview isn't working.

## Testing

To test the implementation:

1. **Text Field:**
   - Open website editor
   - Click on any text element (title, subtitle, etc.)
   - Type in the sidebar text field
   - Verify preview updates in real-time

2. **WYSIWYG Field:**
   - Click on a textarea element
   - Use the rich text editor to format text
   - Verify preview updates with formatting

3. **Image Field:**
   - Click on an image element
   - Select a new image file
   - Verify preview shows the new image immediately

4. **Style Updates:**
   - Switch to "Style" tab
   - Change font size, color, etc.
   - Verify styles update in real-time

## Future Enhancements

Possible improvements:
1. Add debouncing for text input to reduce update frequency
2. Add loading indicator for large images
3. Support for video/audio fields
4. Undo/redo functionality
5. Preview history

## Troubleshooting

**Preview not updating:**
- Check browser console for errors
- Verify field classes match the pattern
- Ensure `editable-field` class is present on preview elements
- Check that `field_name` hidden input exists in the form

**WYSIWYG not working:**
- Verify Quill is loaded (check for `window.Quill`)
- Check that `data-controller="wysiwyg"` is on the container
- Ensure Quill instance is stored on `editorTarget.__quill`

**Images not previewing:**
- Check file input accepts images: `accept="image/*"`
- Verify FileReader API is supported
- Check browser console for file reading errors

