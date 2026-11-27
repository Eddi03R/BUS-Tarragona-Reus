# Brag Plan: ErasBus Tarragona, "Finally on Android"

## What is this app?
A free Flutter app that plans the bus between Reus, Tarragona and Salou for Erasmus students, with night buses to clubs, themes and 25 mini games to beat the wait.

## The angle
"Finally on Android": the app was approved on Google Play. Same quick tour as the iOS video, now on an Android phone (Pixel-style frame, punch-hole camera, Android status bar and gesture bar), with the screens real: a journey (home, results, trip with stops), night buses, four looks (dark, Halloween, Christmas, GTA 6), and the games, ending on the hint button that every game now has. No invented claims: every caption is a real UI string or store headline.

## Hook (0-3.17s)
Logo pops, "Finally on Android." on the app green.

## User flow worth showing
Pick stops → Go → departures list → open a trip with every stop.

## Tone
Preset: app-store; direction: warm, clean feature-card film for a launch day (same as the iOS video).

## Format: vertical, 1080x1920. Duration: 24.07s.
## Visual identity
App green #0b6855, scene colours from the app (purple, pink), Inter 800.

## Audio
No music (the user adds it later). Cuts are locked to the beat grid of the track used for the iOS video (114.84 BPM, t = 0.04 + n x 0.5225 s), so the same track fits. Light UI clicks on cuts and one bong on the outro. No voice.

## Storyboard
1. Hook 0-3.17 · logo + "Finally on Android."
2. Journey 3.17-7.88 · "Plan your bus" / "Every departure, at a glance" / "See every stop"
3. Night 7.88-10.49 · "Night buses to your favourite clubs"
4. Looks 10.49-14.67 · "Pick your look": Dark, Halloween, Christmas, GTA 6 (one cut per 2 beats)
5. Games 14.67-20.94 · "25 mini games" / "Play Briscola against your phone" / "Race the minibus" / "Stuck? Ask for a hint"
6. Outro 20.94-24.07 · logo, "Now on Google Play", "Plan your bus. Beat the wait."

## How the screens are made
`tools/store_screenshots/android_shots_test.dart` renders the real app in a widget test at 1080x2400 (Android phone, English). `prepare_shots.py` redraws the button labels (the test fonts show them as blocks) and writes the webp files. The device frame, status bar and gesture bar are HTML/CSS in `index.html`.
