// Engine_Marimba

// Inherit methods from CroneEngine
Engine_Marimba : CroneEngine {

	// <Marimba> 
	var marimbaSamples;
    var marimbaPlay;
    var marimbaPlaying;
	// </Marimba>

	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	alloc {
		// <Marimba> 
        marimbaPlaying=Dictionary.new();
        marimbaSamples=Array.newClear(20);
        marimbaSamples[0]=Buffer.read(context.server,"/home/we/dust/code/marimba/data/Marimba - White beater - c1 p.wav");
        marimbaSamples[1]=Buffer.read(context.server,"/home/we/dust/code/marimba/data/Marimba - White beater - c1 mp.wav");
        marimbaSamples[2]=Buffer.read(context.server,"/home/we/dust/code/marimba/data/Marimba - White beater - c1 mf.wav");
        marimbaSamples[3]=Buffer.read(context.server,"/home/we/dust/code/marimba/data/Marimba - White beater - c1 f.wav");
        marimbaSamples[4]=Buffer.read(context.server,"/home/we/dust/code/marimba/data/Marimba - White beater - c1 ff.wav");
        marimbaSamples[5]=Buffer.read(context.server,"/home/we/dust/code/marimba/data/Marimba - White beater - c2 p.wav");
        marimbaSamples[6]=Buffer.read(context.server,"/home/we/dust/code/marimba/data/Marimba - White beater - c2 mp.wav");
        marimbaSamples[7]=Buffer.read(context.server,"/home/we/dust/code/marimba/data/Marimba - White beater - c2 mf.wav");
        marimbaSamples[8]=Buffer.read(context.server,"/home/we/dust/code/marimba/data/Marimba - White beater - c2 f.wav");
        marimbaSamples[9]=Buffer.read(context.server,"/home/we/dust/code/marimba/data/Marimba - White beater - c2 ff.wav");
        marimbaSamples[10]=Buffer.read(context.server,"/home/we/dust/code/marimba/data/Marimba - White beater - c3 p.wav");
        marimbaSamples[11]=Buffer.read(context.server,"/home/we/dust/code/marimba/data/Marimba - White beater - c3 mp.wav");
        marimbaSamples[12]=Buffer.read(context.server,"/home/we/dust/code/marimba/data/Marimba - White beater - c3 mf.wav");
        marimbaSamples[13]=Buffer.read(context.server,"/home/we/dust/code/marimba/data/Marimba - White beater - c3 f.wav");
        marimbaSamples[14]=Buffer.read(context.server,"/home/we/dust/code/marimba/data/Marimba - White beater - c3 ff.wav");
        marimbaSamples[15]=Buffer.read(context.server,"/home/we/dust/code/marimba/data/Marimba - White beater - c4 p.wav");
        marimbaSamples[16]=Buffer.read(context.server,"/home/we/dust/code/marimba/data/Marimba - White beater - c4 mp.wav");
        marimbaSamples[17]=Buffer.read(context.server,"/home/we/dust/code/marimba/data/Marimba - White beater - c4 mf.wav");
        marimbaSamples[18]=Buffer.read(context.server,"/home/we/dust/code/marimba/data/Marimba - White beater - c4 f.wav");
        marimbaSamples[19]=Buffer.read(context.server,"/home/we/dust/code/marimba/data/Marimba - White beater - c4 ff.wav");

		context.server.sync;

        SynthDef("marimbax",{
            arg out=0,reverbOut,reverbSend=0,
            velocityMix=0.5,buf1,buf2,t_trig=1,rate=1;
            var snd;
            var sndA,sndA1,sndA2,bufA1,bufA2;
            var sndB,sndB1,sndB2,bufB1,bufB2;
            var switchA,switchB,crossfade;
            var bufrate;

            switchA=ToggleFF.kr(t_trig);
            switchB=1-switchA;
            crossfade=Lag.ar(K2A.ar(switchA),0.01);

            bufA1=Latch.kr(buf1,switchA);
            bufA2=Latch.kr(buf2,switchA);
            bufB1=Latch.kr(buf1,switchB);
            bufB2=Latch.kr(buf2,switchB);

            rate=rate*BufRateScale.kr(buf1);

            sndA1=PlayBuf.ar(2,bufA1,rate,switchA);
            sndA2=PlayBuf.ar(2,bufA2,rate,switchA);
            sndA=SelectX.ar(velocityMix,[sndA1,sndA2],0);

            sndB1=PlayBuf.ar(2,bufB1,rate,switchB);
            sndB2=PlayBuf.ar(2,bufB2,rate,switchB);
            sndB=SelectX.ar(velocityMix,[sndB1,sndB2],0);

            snd = SelectX.ar(1-crossfade,[sndA,sndB],0);
            DetectSilence.ar(snd,0.001,doneAction:2);
            snd = snd/10;
            Out.ar(out,snd);
        }).add;

        marimbaPlay = {
            arg instrument,note,velocity=120;
            var name=instrument.asString++"-"++note.asString;
            var rate=1;
            var availableNotes=[24,36,48,60];
            var sampleStart=availableNotes.indexIn(note);
            var noteDifference=note-availableNotes[sampleStart];
            var ratios=Tuning.et12.ratios;
            var triggered=false;
            var availableVelocities=[-1,128/5,128/5*2,128/5*3,128/5*4,128];
            var velocityClosest=availableVelocities.indexOfGreaterThan(velocity)-1;
            var velocityMix=(velocity-availableVelocities[velocityClosest])/(availableVelocities[velocityClosest+1]-availableVelocities[velocityClosest]);
            ("velocityClosest"+velocityClosest).postln;
            ("velocityMix"+velocityMix).postln;

            if (noteDifference<0,{
                rate = rate/2;
                noteDifference=note-(availableNotes[sampleStart]-12);
            });
            rate = rate * ratios[noteDifference];
            sampleStart = sampleStart * 5;
            ("sampleStart"+sampleStart).postln;

            if (marimbaPlaying.at(name).notNil,{
                if (marimbaPlaying.at(name).isRunning,{
                    triggered=true;
                    marimbaPlaying.at(name).set(\t_trig,1,\rate,rate,\velocity,velocity,
                        \buf1,marimbaSamples[velocityClosest+sampleStart],
                        \buf2,marimbaSamples[1+velocityClosest+sampleStart]
                    );
                });
            });
            if (triggered==false,{
                marimbaPlaying.put(name,Synth("marimbax",[
                    \rate,rate,\velocity,velocity,
                    \buf1,marimbaSamples[velocityClosest+sampleStart],
                    \buf2,marimbaSamples[1+velocityClosest+sampleStart]
                ]).onFree({"freed".postln}));
                NodeWatcher.register(marimbaPlaying.at(name));
            });
        };

		this.addCommand("play","iff", { arg msg;
            marimbaPlay.(msg[1],msg[2],msg[3]);
		});
        
		// </Marimba> 

	}

	free {
		// <Marimba> 
		marimbaPlaying.keysValuesDo({ arg key, value; value.free; });
		(0..19).do({ arg i; marimbaSamples[i].free; });
		// </Marimba> 
	}
}
