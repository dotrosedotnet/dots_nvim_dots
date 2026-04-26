local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmta = require("luasnip.extras.fmt").fmta

local helpers = require("dot.luasnip.helpers")

local function autosnip(trig, body)
	return s({ trig = trig, condition = helpers.in_sc_code }, body)
end

local regular = {}

local autosnippets = {
	-- Blocks: JITLib + traditional
	autosnip(
		"sd",
		fmta(
			[[
SynthDef(\<>, { |out = 0, freq = 440, amp = 0.2, gate = 1, att = 0.01, sus = 1, rel = 1, pan = 0|
	var sig, env;
	env = EnvGen.kr(Env.adsr(att, 0.1, sus, rel), gate, doneAction: 2);
	sig = <>;
	Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;
]],
			{ i(1, "name"), i(2) }
		)
	),
	autosnip("ndef", fmta("Ndef(\\<>, { <> }).play;", { i(1, "name"), i(2) })),
	autosnip(
		"pdef",
		fmta(
			[[
Pdef(\<>,
	Pbind(
		\instrument, \<>,
		\dur, <>,
		<>
	)
).play;
]],
			{ i(1, "name"), i(2, "instr"), i(3, "0.25"), i(4) }
		)
	),
	autosnip(
		"pb",
		fmta(
			[[
Pbind(
	\instrument, \<>,
	\dur, <>,
	<>
).play;
]],
			{ i(1, "instr"), i(2, "0.25"), i(3) }
		)
	),

	-- Oscillators
	autosnip("sin", fmta("SinOsc.ar(<>, <>, <>, <>)", { i(1, "freq"), i(2, "0"), i(3, "1"), i(4, "0") })),
	autosnip("saw", fmta("Saw.ar(<>)", { i(1, "freq") })),
	autosnip("pulse", fmta("Pulse.ar(<>, <>)", { i(1, "freq"), i(2, "0.5") })),
	autosnip("lfn", fmta("LFNoise1.kr(<>)", { i(1, "rate") })),

	-- Modulation / excitation
	autosnip("lfsaw", fmta("LFSaw.kr(<>)", { i(1, "rate") })),
	autosnip("dust", fmta("Dust.ar(<>)", { i(1, "density") })),

	-- Envelopes (full EnvGen wrappers)
	autosnip(
		"env",
		fmta(
			"EnvGen.kr(Env.adsr(<>, <>, <>, <>), <>, doneAction: 2)",
			{ i(1, "att"), i(2, "dec"), i(3, "sus"), i(4, "rel"), i(5, "gate") }
		)
	),
	autosnip(
		"perc",
		fmta("EnvGen.kr(Env.perc(<>, <>), doneAction: 2)", { i(1, "0.01"), i(2, "0.3") })
	),

	-- Filters
	autosnip("lpf", fmta("LPF.ar(<>, <>)", { i(1, "in"), i(2, "freq") })),
	autosnip("rlpf", fmta("RLPF.ar(<>, <>, <>)", { i(1, "in"), i(2, "freq"), i(3, "rq") })),
	autosnip("bpf", fmta("BPF.ar(<>, <>, <>)", { i(1, "in"), i(2, "freq"), i(3, "rq") })),

	-- Mix / spatial / utility
	autosnip("splay", fmta("Splay.ar([<>])", { i(1) })),
	autosnip("lag", fmta("Lag.kr(<>, <>)", { i(1, "in"), i(2, "lagTime") })),
	autosnip("decay", fmta("Decay.ar(<>, <>)", { i(1, "trig"), i(2, "decayTime") })),
}

return regular, autosnippets
