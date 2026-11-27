# Hyperframes Composition Brief: ErasBus Tarragona (Android)

Composition: `tools/brag-video-android/index.html` (single file, GSAP timeline, 1080x1920, 24.07s).
Output: `store/video/brag-android.mp4`, poster `store/video/brag-android.jpg`, copy `store/video/share-copy-android.txt`.
Source of truth: `brag-plan.md` (storyboard) and the iOS composition in `tools/brag-video/` (same structure and beat grid).
Copy that must appear verbatim: "Finally on Android.", "Now on Google Play", "Plan your bus. Beat the wait."
Audio: no music; SFX from `assets/sfx` on the beat cuts; the track is added by the user later.
Render: `npx hyperframes@0.9.88 check` then `npx hyperframes@0.9.88 render --output ../../store/video/brag-android.mp4`.
