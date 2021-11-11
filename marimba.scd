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
SynthDef("marimba",{
	arg out=0,velocity=80,buf1,buf2,buf3,buf4,buf5,t_trig=1,rate=1;
	var snd,snd1,snd2,snd3,snd4,snd5;
	snd1=PlayBuf.ar(2,buf1,BufRateScale.kr(buf1)*rate,t_trig);
	snd2=PlayBuf.ar(2,buf2,BufRateScale.kr(buf2)*rate,t_trig);
	snd3=PlayBuf.ar(2,buf3,BufRateScale.kr(buf3)*rate,t_trig);
	snd4=PlayBuf.ar(2,buf4,BufRateScale.kr(buf4)*rate,t_trig);
	snd5=PlayBuf.ar(2,buf5,BufRateScale.kr(buf5)*rate,t_trig);
	snd=SelectX.ar(Clip.kr(velocity/127*5,0,5),[snd1,snd2,snd3,snd4,snd5],0);
	DetectSilence.ar(snd,doneAction:2);
	Out.ar(out,snd);
}).add;
)

(
SynthDef("marimbax",{
	arg out=0,velocityMix=0.5,buf1,buf2,t_trig=1,rate=1;
	var snd;
	var sndA,sndA1,sndA2;
	var sndB,sndB1,sndB2;
	var switchA,switchB,crossfade;
	var bufrate;

	switchA=ToggleFF.kr(t_trig);
	switchB=1-switchA;
	crossfade=Lag.ar(K2A.ar(switchA),0.01);

	rate=rate*BufRateScale.kr(buf1);

	sndA1=PlayBuf.ar(2,buf1,rate,switchA);
	sndA2=PlayBuf.ar(2,buf2,rate,switchA);
	sndA=SelectX.ar(velocityMix,[sndA1,sndA2],0);

	sndB1=PlayBuf.ar(2,buf1,rate,switchB);
	sndB2=PlayBuf.ar(2,buf2,rate,switchB);
	sndB=SelectX.ar(velocityMix,[sndB1,sndB2],0);

	snd = SelectX.ar(1-crossfade,[sndA,sndB],0);
	DetectSilence.ar(snd,0.001,doneAction:2);
	Out.ar(out,snd/2);
}).add;
)

x=Synth("marimbax",[\rate,0.5,\velocity,32,\buf1,~marimbaSamples[0],\buf2,~marimbaSamples[1],\buf3,~marimbaSamples[2],\buf4,~marimbaSamples[3],\buf5,~marimbaSamples[4]]);
x.set(\t_trig,1);

127/5
[12.7,25.4*1+12.7,25.4*2+12.7,25.4*3+12.7,25.4*4+12.7].indexIn(32)

a=[-1,31.75,31.75*2,31.75*3,128];
i=a.indexOfGreaterThan(120)-1;
(120-a[i])/(a[i+1]-a[i])

[-1,31.75,31.75*2,31.75*3,128].indexInBetween(120)

128/5
(
~notesPlaying=Dictionary.new();
~play={
	arg note,velocity=120;
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


	if (~notesPlaying.at(note).notNil,{
		if (~notesPlaying.at(note).isRunning,{
			triggered=true;
			~notesPlaying.at(note).set(\t_trig,1,\rate,rate,\velocity,velocity,
				\buf1,~marimbaSamples[velocityClosest+sampleStart],
				\buf2,~marimbaSamples[1+velocityClosest+sampleStart]
			);
		});
	});
	if (triggered==false,{
		~notesPlaying.put(note,Synth("marimbax",[\rate,rate,\velocity,velocity,
			\buf1,~marimbaSamples[velocityClosest+sampleStart],
			\buf2,~marimbaSamples[1+velocityClosest+sampleStart]
		]).onFree({"freed".postln}));
		NodeWatcher.register(~notesPlaying.at(note));
	});
};
)

~play.(60,10);
~play.(24,120);

(
~play.(50-12,120);
~play.(53,40);
~play.(57,20);
)
