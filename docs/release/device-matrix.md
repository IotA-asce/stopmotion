# Device Matrix

| Platform | Required baseline | Evidence required | Status |
| --- | --- | --- | --- |
| Android | Android 10 lower-memory device | Capture, import, export, low storage, TalkBack, 200% text, repeated cancel | Pending physical run |
| Android | Current Android device | Camera lifecycle, volume shutter, MediaStore/share, codec playback, keyboard | Pending physical run |
| iPhone | iOS 15 device | Capture/audio interruption, Photos/Files, VoiceOver, low storage, codec playback | Pending physical run |
| iPhone | Current iOS device | Lifecycle, export/share, 200% text, memory, repeated cancel | Pending physical run |

Record model, OS build, app commit, fixture, raw timings, output probe result, and pass/fail result for every run. CI builds are not substitutes for this matrix.
