## Introduction on FC(C)S/FLIM
[PicoQuant knowledgebase](https://www.picoquant.com/scientific/technical-and-application-notes/category/technical_notes_techniques_and_methods/P8)

[Malacrida et al., 2021](https://www.annualreviews.org/doi/10.1146/annurev-biophys-062920-063631) on the phasor plot

## Prerequisite
This toolkit requires another repository of mine, [readHeader](https://github.com/CreLox/readHeader), to run.

## General workflow
The [workflow routine](https://github.com/CreLox/FluorescenceLifetime/blob/master/Workflows/PhasorIntensityFiltersFLIMFitting.m) demonstrates all the steps in a typical data analysis: intensity thresholding (for localized fluorophores), phasor plot-based pixel filtering, region exclusion (manual correction), and fitting. Use ``Run Section`` in MATLAB to perform your analysis in a guided, step-by-step manner.

## Principles
At long last, GitHub Markdown now supports [math expressions](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/writing-mathematical-expressions) natively (from May 2022)!

To demonstrate how fluorescence lifetime measurements can quantify the FRET efficiency, consider a large number of donor fluorophore molecules with a lifetime of $τ_0$. In the absence of acceptor fluorophores, the exponential decay $D_0$ of donor fluorescence after pulsed excitation at time zero is
$$D_0(t) = Ce^{-t/τ_0}.$$
The total donor fluorescence signal (which can be measured through FLIM) is
$$S_0=\int_0^{+\infty} D_0(t)dt = Cτ_0,$$
wherein the pre-exponential factor $C$ is a constant determined by the total number and properties of fluorophores, as well as the imaging setup. Without altering any of these conditions, in the presence of acceptor fluorophores and FRET, the possibility that an excited fluorophore stays excited (has not relaxed to the ground state either through the fluorescence-emitting route or the FRET-quenching route) at time $t$ is
$$P=e^{-(1/τ_0 +1/τ')t},$$
wherein $τ'$ ( $=(r/R_0)^6τ_0$; see the derivation of equation 15.2.27 [here](https://chem.libretexts.org/Bookshelves/Physical_and_Theoretical_Chemistry_Textbook_Maps/Time_Dependent_Quantum_Mechanics_and_Spectroscopy_(Tokmakoff)/15%3A_Energy_and_Charge_Transfer/15.02%3A_Forster_Resonance_Energy_Transfer_(FRET))) is the time parameter of FRET (note: although an excited fluorophore can only relax through one route, the two stochastic processes – fluorescence-emitting and FRET-quenching – are independent). Therefore, in the presence of acceptor fluorophores and FRET, the new decay dynamics $D$ of donor fluorescence becomes
$$D(t)=Ce^{-(1/τ_0 +1/τ')t}=Ce^{-(τ_0+τ')t/(τ_0 τ')},$$
The **effective lifetime** of the donor fluorophore (which can be measured through FLIM) becomes
$$τ=\frac{τ_0 τ'}{τ_0+τ'},$$
and the total donor fluorescence signal becomes $S = Cτ$. Therefore, the FRET efficiency
$$\frac{S_0-S}{S_0}=\frac{τ_0-τ}{τ_0}(=\frac{1}{(r/R_0)^6+1}),$$
wherein $τ_0$ and $τ$ can be measured through FLIM. Because the fluorescence lifetime in the absence of quenching is an intrinsic property of a mature fluorescent protein under a certain temperature (see [section 9.4.5.1, Kafle, 2020](https://www.sciencedirect.com/science/article/pii/B9780128148662000099)), the equation above greatly simplifies the FRET efficiency measurement. This equation still applies even if the fluorescence decay must be fitted by a multi-component exponential decay, as long as the fluorescence lifetime is an average value weighted by the corresponding $C$ of each component (see the section below).

## Excluding autofluoresence pixels based on the phasor transformation
The phasor transformation is a normalized Fourier transformation that converts time-resolved emission data into a single point in the complex plane. For a donor fluorophore with an exponential decay $D(t) = Ce^{-t/τ}$ after pulsed excitation at time zero and any positive $\omega$ with a dimension of $s^{-1}$, the phasor transformation of $D(t)$ is defined as
$$\mathcal{P}(\omega, D) = (\int_0^{+\infty} e^{i \omega t}D(t)dt)/(\int_0^{+\infty} D(t)dt) = \frac{1}{1+\omega^2\tau^2} + \frac{\omega\tau}{1+\omega^2\tau^2}i.$$
For discrete time-resolved emission data, suppose that the arrival micro-time (after pulsed excitation at time zero) of a series of photon $n  (n = 1, 2, ..., N$) is $t_n$. The phasor transformation of the series is then
$$\mathcal{P}(\omega) = \sum_{n=0}^{N} e^{i \omega t_n}/N.$$
The corresponding phasor $\frac{1}{1+\omega^2\tau^2} + \frac{\omega\tau}{1+\omega^2\tau^2}i$ on the complex plane $G+Si \rightarrow (G, S), G, S \in \mathbb R$, is distributed on the semicircle
$$(G-1/2)^2+S^2 = 1/4, S>0.$$
For an ensemble of fluorophores with different exponential decay lifetimes, the phasor is a linear combination of the phasors of the composing species $(1, 2, ..., M)$ weighted by their corresponding **fractional intensity**:
$$\mathcal{P}(\omega) = \sum_{m=0}^{M} (\mathcal{P_m}(\omega) \cdot \frac{C_m\tau_m}{\sum_{l=0}^{M} C_l\tau_l}).$$
## A note on the multi-component exponential fit
As [Knight and Selinger (1971)](https://www.sciencedirect.com/science/article/pii/0584853971800739) put it,

> ... Without careful consideration of the nature of the problem, deconvolution as an information-improving device can easily become an exercise in self-delusion.

The FLIM signal is derived from the instrument response function (IRF) $\circledast$ the (multi-component) exponential decay $D(t)$ + noise. However, the multi-component exponential fit is intrinsically flexibile. Regarding this, [Grinvald and Steinberg (1974)](https://www.sciencedirect.com/science/article/pii/0003269774903121) raised two very educational examples which are reproduced here:

<img width="810" alt="image" src="https://user-images.githubusercontent.com/18239347/184480647-87a58ad1-fc0d-4daf-a830-a7bf177ed668.png">

However, the average lifetime of a **good** multi-component exponential fit weighted by the corresponding $C$ of each component (see the section above) should be conserved, regardless of the actual fitting parameters (because both $S$, the area underneath the curve, and $D(0)$, the intersection point at $t = 0$, should be close for all **good** fits):
$$\bar{\tau} = \frac{\sum C_i \tau_i}{\sum C_i} = \frac{S}{D(0)}.$$

## Prepulse and afterpulse in the measured IRF
Our current protocol uses a mirror on the sample plane to measure the IRF. The emission filter is removed and internal reflection at lenses is observed as a prepulse in the measured IRF. This prepulse is an artifact due to the removal of the emission filter and should be manually removed in postprocessing. Additionally, the avalanche photodiode (APD) detector has an afterpulse feature (see, for example, [Ziarkash et al., 2018](https://www.nature.com/articles/s41598-018-23398-z)). This is intrinsic to the detector and an integral part of the IRF that should NOT be removed in postprocessing.

## Normalization of event counts
Alba is a laser scanning microscopy setup. The amplification factor is determined by the setup and the objective but not by the scale of the FOV set for scanning. Therefore, the power of the excitation light on the sample plane and the corresponding area on the sample plane of the APD detector are not affected by the FOV set for scanning. Because the pixel dwell time is fixed, the event count per **pixel** is directly comparable, regardless of the scale of the FOV set for scanning.

## Acknowledgments
I would like to thank Dr. J. Damon Hoff (from the SMART Center at the Univerisity of Michigan, Ann Arbor) for his suggestions on the manual and his ground-laying contributions to scripts related to the I/O of data files.
