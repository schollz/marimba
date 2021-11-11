(
~marimbaSamples=Array.newClear(20);
~marimbaSamples[0]=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/Marimba - White beater - c1 p.wav");
~marimbaSamples[1]=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/Marimba - White beater - c1 mp.wav");
~marimbaSamples[2]=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/Marimba - White beater - c1 mf.wav");
~marimbaSamples[3]=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/Marimba - White beater - c1 f.wav");
~marimbaSamples[4]=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/Marimba - White beater - c1 ff.wav");
~marimbaSamples[5]=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/Marimba - White beater - c2 p.wav");
~marimbaSamples[6]=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/Marimba - White beater - c2 mp.wav");
~marimbaSamples[7]=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/Marimba - White beater - c2 mf.wav");
~marimbaSamples[8]=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/Marimba - White beater - c2 f.wav");
~marimbaSamples[9]=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/Marimba - White beater - c2 ff.wav");
~marimbaSamples[10]=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/Marimba - White beater - c3 p.wav");
~marimbaSamples[11]=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/Marimba - White beater - c3 mp.wav");
~marimbaSamples[12]=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/Marimba - White beater - c3 mf.wav");
~marimbaSamples[13]=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/Marimba - White beater - c3 f.wav");
~marimbaSamples[14]=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/Marimba - White beater - c3 ff.wav");
~marimbaSamples[15]=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/Marimba - White beater - c4 p.wav");
~marimbaSamples[16]=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/Marimba - White beater - c4 mp.wav");
~marimbaSamples[17]=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/Marimba - White beater - c4 mf.wav");
~marimbaSamples[18]=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/Marimba - White beater - c4 f.wav");
~marimbaSamples[19]=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/Marimba - White beater - c4 ff.wav");
)

(
SynthDef("mxfx",{
	arg inDelay, inReverb, reverb=0.05, out, secondsPerBeat=1,delayBeats=4,delayFeedback=0.1,bufnumDelay;
	var snd,snd2,y,z;
	// reverb
	snd2 = In.ar(inReverb,2);
	snd2 = DelayN.ar(snd2, 0.03, 0.03);
	snd2 = CombN.ar(snd2, 0.1, {Rand(0.01,0.099)}!32, 4);
	snd2 = SplayAz.ar(2, snd2);
	snd2 = LPF.ar(snd2, 1500);
	5.do{snd2 = AllpassN.ar(snd2, 0.1, {Rand(0.01,0.099)}!2, 3)};
	snd2 = LPF.ar(snd2, 1500);
	snd2 = LeakDC.ar(snd2);
	Out.ar(out,snd2);
}).add;
SynthDef("marimba",{
	arg out=0,outReverb,reverbSend=0,velocity=80,buf1,buf2,buf3,buf4,buf5,t_trig=1,rate=1;
	var snd,snd1,snd2,snd3,snd4,snd5;
	snd1=PlayBuf.ar(2,buf1,BufRateScale.kr(buf1)*rate,t_trig);
	snd2=PlayBuf.ar(2,buf2,BufRateScale.kr(buf2)*rate,t_trig);
	snd3=PlayBuf.ar(2,buf3,BufRateScale.kr(buf3)*rate,t_trig);
	snd4=PlayBuf.ar(2,buf4,BufRateScale.kr(buf4)*rate,t_trig);
	snd5=PlayBuf.ar(2,buf5,BufRateScale.kr(buf5)*rate,t_trig);
	snd=SelectX.ar(Clip.kr(velocity/127*5,0,5),[snd1,snd2,snd3,snd4,snd5],0);
	DetectSilence.ar(snd,doneAction:2);
	Out.ar(out,snd);
	Out.ar(outReverb,snd*reverbSend);
}).add;
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
	Out.ar(reverbOut,snd*MouseX.kr());
}).add;
)

x=Synth("marimbax",[\rate,0.5,\velocity,32,\buf1,~marimbaSamples[0],\buf2,~marimbaSamples[1],\buf3,~marimbaSamples[2],\buf4,~marimbaSamples[3],\buf5,~marimbaSamples[4]]);
x.set(\t_trig,1);

(
~busReverb = Bus.audio(s,2);
~fx = Synth.new("mxfx",[\out,0,\inReverb,~busReverb]);
~notesPlaying=Dictionary.new();
~play={
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


	if (~notesPlaying.at(name).notNil,{
		if (~notesPlaying.at(name).isRunning,{
			triggered=true;
			~notesPlaying.at(name).set(\t_trig,1,\rate,rate,\velocity,velocity,
				\buf1,~marimbaSamples[velocityClosest+sampleStart],
				\buf2,~marimbaSamples[1+velocityClosest+sampleStart]
			);
		});
	});
	if (triggered==false,{
		~notesPlaying.put(name,Synth("marimbax",[
			\rate,rate,\velocity,velocity,
			\reverbOut,~busReverb,
			\reverbSend,0.3,
			\buf1,~marimbaSamples[velocityClosest+sampleStart],
			\buf2,~marimbaSamples[1+velocityClosest+sampleStart]
		]).onFree({"freed".postln}));
		NodeWatcher.register(~notesPlaying.at(name));
	});
};
)


~play.(1,60,10);
~play.(1,50,30);


(
~dobass=0;
~dochords=0;
~onenote=50;
r=Routine{
	var chords=Pseq([
		1,0,0,1,
		0,0,1,0,
		0,0,1,0,
		0,1,0,0
	],inf).asStream;
	var bass=Pseq([
		1,0,0,0,
		0,1,0,0,
		1,0,1,0,
		1,0,0,0,
		0,1,0,0,
		0,1,0,0,
		0,0,1,0,
		1,0
	],inf).asStream;
	var bassnotes=Pseq([50-24,53-24,57-24,48-24,45-24,41-24,50-24,57-24],inf).asStream;
	var notes=Pseq([
		57,57,57,57,57,
		58,58,58,58,58,
		57,57,57,57,57,
		62,62,62,62,62,
	],inf).asStream;
	var rr=Prand(
		[-15,-10,-5,-4,-3,-2,-1,0,1,2,3,4,5,10,15],
		inf).asStream;
	var accent=Pseq([1,0,0,1,0,0,1,0,1,0,1,0,1,0,1,0],inf).asStream;
	loop {
		(1/6.5).wait;
		~play.(1,~onenote,30+(60*accent.next)+rr.next);
		if (chords.next>0&&(~dochords>0),{
			~play.(2,50-12,60+rr.next);
			~play.(2,53,70+rr.next);
			~play.(2,notes.next,50+rr.next);
		});
		if (bass.next>0&&(~dobass>0),{
			~play.(3,bassnotes.next,60);
		});
	}
}.play;
)

~dobass=0;
~dochords=0;
~onenote=50;

~dochords=1;
~onenote=53;
~onenote=48;
~onenote=45;
~onenote=50;
~onenote=41;


r.stop;


~play.(2,50-36,60);

(
~play.(2,50-12,120);
~play.(2,53,40);
~play.(2,57,20);
)

(
~play.(2,50-12,120);
~play.(2,53,40);
~play.(2,58,20);
)
(
~play.(2,50-12,120);
~play.(2,53,40);
~play.(2,62,50);
)
