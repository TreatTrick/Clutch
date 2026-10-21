# Website dragon maid

## Approved behavior

Reuse Clutch's existing dragon maid at the website's bottom-right corner. Allow horizontal dragging with mouse or touch, and arrow-key movement when focused. The user confirmed that proximity to the top edge of the web page should approximate browser-close intent; the page must not claim to know the actual browser tab close-button position. Approaching that edge plays toward sadness, moving away plays toward happiness. Every download link triggers the existing jumping animation without delaying or preventing the download.

## Implementation

1. Decode the transparent, aligned multi-image HEIC clips from Clutch/Mascot into two transparent WebP sprite atlases and one happy still, preserving their shared canvas and original 24 fps. Keep generated browser assets tracked; Python is only needed to regenerate them.
2. Add a self-contained Svelte Mascot component using a small canvas. The animation clock uses elapsed time, stops at endpoints, pauses while the page is hidden, and respects reduced motion. Keep normal playback, celebration, and dragging independent.
3. Track mouse direction only within the top quarter of the viewport (capped at 200 px); outside that zone always cheer up. Filter small movement jitter. A pointer leaving through the top also expresses sadness. No unload warning, exit interception, or download interception.
4. Constrain horizontal position to the viewport with padding, persist a normalized position across language changes and screen sizes, and provide localized accessible instructions. Keep the existing landing page and appearance styles intact.
5. Wire both download anchors to the same celebration signal. Include three-language labels and a static fallback if image decoding fails or reduced motion is enabled.

## Validation and delivery

Run pnpm check, pnpm build, and git diff --check. Inspect extracted stills and atlas metadata. The user prefers to verify page interaction in Pages; do not start an additional browser QA session. Commit and push the website change, then confirm the deployment workflow result.
