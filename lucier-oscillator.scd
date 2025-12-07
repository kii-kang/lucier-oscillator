// Boot server first.
s.waitForBoot({
    // Base pitch: E4 in 12-TET; adjust to match your instrument
    var e4 = 329.62755691287; // Hz

    // Utility: semitone offset -> Hz
    var semiToHz = { |base, semi| base * (2 ** (semi / 12)) };

    // Durations (seconds) from the instructions
    var up18  = 18 * 24;  // 432 s up (24 semitones)
    var dn22  = 22 * 24;  // 528 s down
    var fadeIn = 10;      // 10 s before sweep

    // SynthDef with piecewise linear envelopes in SEMITONES.
    SynthDef(\lucierSweepPair, {
        var envSemi1, envSemi2, semi1, semi2, f1, f2, ampEnv, sigL, sigR;

        // Oscillator 1 (Left): 0 -> +24 semitones (432s), then +24 -> 0 (528s)
        envSemi1 = Env([0, 24, 0], [up18, dn22], \lin);
        semi1    = EnvGen.kr(envSemi1, doneAction: 0);

        // Oscillator 2 (Right): 0 -> -24 semitones (528s), then -24 -> 0 (432s)
        envSemi2 = Env([0, -24, 0], [dn22, up18], \lin);
        semi2    = EnvGen.kr(envSemi2, doneAction: 0);

        // Convert to Hz
        f1 = semiToHz.(e4, semi1);
        f2 = semiToHz.(e4, semi2);

        // Global amplitude envelope: 10s fade-in, sustain through both sweeps, short fade-out
        ampEnv = EnvGen.kr(
            Env.linen(fadeIn, up18 + dn22, 5, level: (-18).dbamp),  // conservative level
            doneAction: 2
        );

        sigL = SinOsc.ar(f1);
        sigR = SinOsc.ar(f2);

        // Hard-pan left/right, scale by amp
        Out.ar(0, [sigL, sigR] * ampEnv);
    }).add;

    // Play it
    x = Synth(\lucierSweepPair);
});
