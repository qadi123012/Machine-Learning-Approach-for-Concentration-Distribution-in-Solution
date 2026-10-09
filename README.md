Simultaneous Quantitative Schlieren and PIV for Cu2+ Concentration and Velocity in Copper Electroplating

Show Image Show Image

Code, tables and simulations that go with the paper "A Novel Approach to Simultaneous Quantitative Schlieren and Particle Image Velocimetry for Coupled Measurement of Concentration and Velocity Fields in Copper Electroplating" (Abdul Qadir, Zuimiao Tao, Yan Cao; Guangzhou Institute of Energy Conversion, CAS, and University of Science and Technology of China).

The experiment in one paragraph

Copper is plated from a 0.100 g/mL Cu2+ bath at 185 A/m2 between two electrodes 20 mm apart (anode at x = 0, cathode at x = 20 mm). A single camera and one cell are used for two measurements at once. A knife-edge Schlieren arrangement turns refractive-index gradients into grey values, which are calibrated pixel by pixel and integrated into Cu2+ concentration maps. A pulsed laser sheet and 10 um glass tracers give PIV velocity fields on the same frames. The two are co-registered so that concentration and flow can be read together. Over 15 minutes the cell moves through three stages: a diffusion-dominated start, a transition with a recirculating roll, and a quasi-steady convective state.

Where things are
.
├── README.md                this file
├── codes/                   all Python code, tests and the run script
├── concentration/           Schlieren to concentration: data, simulations, paper figures, explanation
├── PIV/                     velocity fields: data, simulations, paper figures, explanation
├── requirements.txt
├── LICENSE
└── CITATION.cff
Folder	Start with	What is inside
codes/	run_all.sh	package schlierenpiv/, six numbered scripts, your image-enhancement script, 11 unit tests
concentration/	its README	Table 1 and 2 data, derived numbers, simulations S1 to S7, Figs. 1 to 10 of the paper
PIV/	its README	PIV parameters, tracer numbers, simulations P1 to P5, Figs. 11 to 15 of the paper
Quick start
bash
pip install -r requirements.txt
bash codes/run_all.sh          # tests + every simulation, about one minute

Each script can also be run alone, for example python codes/04_piv_simulation.py. Outputs land in concentration/simulations/ and PIV/simulations/.

What the simulations are, and what they are not

The experimental images, calibration data and vector fields are not part of this repository (the manuscript's data statement says they are institute-restricted). Everything here is built from the numbers printed in the paper:

a forward model of the knife-edge Schlieren chain and of PIV imaging,
stand-in fields (concentration and velocity) constructed from Tables 1 and 2 and the quoted peak velocities,
the inversion and PIV processing applied to those synthetic frames, so that errors can be measured against a known truth.

So the results answer "what does this measurement chain recover, and where does it break?". They do not reproduce the measured fields. Quantities the manuscript does not give (focal length, source-image size, noise level, stratification amplitude and similar) are marked [assumed] in codes/schlierenpiv/constants.py. Change them to your instrument values and rerun.

Headline findings

Numbers in the paper that check out. Every derived quantity I recomputed matches the printed value: Faraday flux 6.09e-5 kg/m2s, km,req = 7.43e-7 m/s, km,opt = 7.44 / 8.40 / 9.52e-7 m/s, Re = 36 and 297, Pe = 4.16e5, Stokes number 7.8e-7, Sh = 187.8, and the PIV displacements of 0.64, 5.28 and 6.4 px. See concentration/data/derived_transport_numbers.csv.

Schlieren concentration (assumed optics, 91.7 % of pixels in range, paper: 91 %)

Finding	Value
Noise-limited error once the bulk reference is removed	about 0.05 kg/m3
Error caused by assuming the bulk reference equals Cb while stratification and plumes exist	1.7 kg/m3 (stage 2), 2.9 kg/m3 (stage 3)
Width of the saturated band at each electrode	5.5 to 9.5 pixels (0.7 to 1.2 mm)
Cathode wall concentration recovered by extrapolating the in-range pixels	not recoverable: linear extrapolation returns 96 to 100 kg/m3 for a true 22 to 83
Gradient range needed to resolve the layer	about 110 kg/m3 per mm, versus 6.7 kg/m3 per mm for a 0.9 mm knife-edge window

PIV (64 to 32 px windows, dt = 0.1 s)

Finding	Value
Sub-pixel RMS error	0.04 to 0.06 px
Relative error at 0.64 px (stage 1) and at 5.28 px (stage 2)	9.2 % and 0.8 %
RMS velocity error, stages 1, 2, 3	6.1 %, 2.9 %, 4.1 % (manuscript quotes 2.1 % for stages 2 and 3)
Peak speed recovered	9 %, 5 %, 7 % low, because 32 px windows (4 mm) average narrow plumes
Nearest vector to an electrode	2.0 mm, so no vector samples the 0.75 mm layer

Pre-processing. Applying the display enhancement (blur + CLAHE + gamma 0.9) before inversion multiplies the reconstruction error by about 100 (0.05 to 5.1 kg/m3). Median filtering does not.

Points worth checking before this goes public

These came up while building the project. None changes the paper's arithmetic, but a reader or reviewer could raise them.

Cs = 18 +/- 2 kg/m3 and delta_c = 0.75 +/- 0.08 mm depend on extrapolation across a saturated band. In the simulations the near-electrode gradient (about 110 kg/m3 per mm for a 0.75 mm layer) is far outside what a 0.19 mm x 10 position knife-edge sweep can measure, and the paper's own 91 % monotonic fraction is consistent with a saturated band of that width (the assumed focal length was chosen to match it, so this is a consistency check, not a proof). If your real optical range is wider, the conclusion changes, but the extrapolation method and its uncertainty should be stated. Also, 0.75 mm is exactly 6.0 native pixels.
The film-model result exceeds the Faraday limit. For any monotone concave profile, delta99 cannot be smaller than 0.99 x D (Cb - Cs) / J = 0.95 mm when the wall flux equals the Faraday flux. The reported 0.75 mm implies a wall flux 1.28 times the Faraday flux for a linear film, and 2.6 or 5.9 times for erf or exponential profiles. The paper notes the excess; the bound gives it a sharper form.
The 0.99 Cb criterion tolerates 1 kg/m3, but the stated precision is 2.0 kg/m3 (2 sigma). delta99 is therefore noise-sensitive.
CLAHE before quantitative inversion (Section 2.4) is not compatible with a fixed pixel-wise calibration. See concentration/simulations/S6_preprocessing_effect.png.
Grashof number. The beta_s used for Gr = 7.33e6 is not given; it implies 1.0e-4 m3/kg. The Sherwood correlation Sh = 0.59 Ra^(1/4) is usually quoted for Ra below 1e9, and here Ra = 1.03e10.
The earlier simulation repository (electroplating_simulation.py) does not match this revision. It places the cathode at x = 0 (this paper: anode at 0), uses beta_s = 0.145 m3/kg, and validates against "delta_c = 0.96 mm, km = 7.44e-7, Cs = 18, Vmax = 7.5 mm/s", which mixes stage 1 values (0.96 mm, 7.44e-7) with stage 3 values (Cs = 18) and a velocity the paper does not quote. Update or clearly label it before publishing both.
Fig. 15 (diffusion+migration vs convection split) is not derivable from the text. Its values are only transcribed (PIV/data/).
Paper figures are included as images. Check institute policy and journal copyright before making the repository public, and anonymity rules if the review is still blind.
Citation and license

Please cite the paper once it is published (add the DOI to CITATION.cff). MIT license, see LICENSE.

Contact

Corresponding author: Prof. Yan Cao, Guangzhou Institute of Energy Conversion, Chinese Academy of Sciences. Code questions: please open a GitHub Issue.
