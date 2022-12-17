## Introduction on Fluorescence Lifetime Imaging Microscopy (FLIM)
[PicoQuant knowledgebase](https://www.picoquant.com/scientific/technical-and-application-notes/category/technical_notes_techniques_and_methods/P8)

[Jung et al., 2011](https://link.springer.com/chapter/10.1007/4243_2011_14) on the fluorescence lifetime of fluorescent proteins

[Malacrida et al., 2021](https://www.annualreviews.org/doi/10.1146/annurev-biophys-062920-063631) on the phasor plot, especially literature [45, 46, 54, 59, 60, 61] cited in this review.

## Specifications
This toolkit analyzes raw FLIM data (in .iss-tdflim files acquired by VistaVision) obtained by an Alba v5 scanning confocal microscope equipped with a 20-MHz pulsed excitation light source. Photons are detected by an SPCM-AQRH-15 avalanche photodiode (APD). The time-correlated single photon counting module (which registers detected photon events to their corresponding excitation pulses) is an SPC-830.

## General workflow
(Note: steps 1-3 are only needed to be done once per experiment.)

1. Open MATLAB. In the Command Window, call the `calculateIRF` function and pick the .fcs file containing the instrument response function (IRF) measurement data in the pop-up UI. Note that this requires another repository of mine, [readHeader](https://github.com/CreLox/readHeader), to function. The normalized IRF is then automatically saved into a .mat file with the same filename as the original .fcs input file. Load it to continue later steps.

```MATLAB
>> calculateIRF('Early'); % For the green channel, specify the early pulse.
```

2. Visually examine the IRF curve. Optional: if you see a major prepulse before the main IRF spike, remove it manually by assigning those `IRFProb` values belonging to the prepulse to 0. The reason is explained in [a section below](https://github.com/CreLox/FluorescenceLifetime#prepulse-and-afterpulse-in-the-measured-irf). However, if you do this, make sure to renormalize the `IRFProb`.

```MATLAB
>> plot(25/4096:50/4096:25-25/4096, IRFProb, '.-'); % A ClockFrequency of 20 MHz and an ADCResolution of 4096 were used
   ...
>> % IRFProb = IRFProb / sum(IRFProb); % Normalization again
```

3. Calculate `IRFTransform`. Do not use other values for $\omega$ because the empirical standards (hard-coded in the third step of the [workflow routine](https://github.com/CreLox/FluorescenceLifetime/blob/master/Workflows/PhasorIntensityFiltersFLIMFitting.m)) to identify autofluorescent pixels depend on $\omega$. For more details, see [another section below](https://github.com/CreLox/FluorescenceLifetime#phasor-transform-and-autofluorescence-filtering). Save `IRFProb`, `Omega`, and `IRFTransform` into a single .mat file.

```MATLAB
>> Omega = calculateBestOmega(2, 3); % ~ 0.4082, which optimally resolves fluorescence lifetimes in the 2-3 ns range.
>> IRFTransform = calculateIRFTransform(IRFProb, 25/4096:50/4096:25-25/4096, Omega); % A ClockFrequency of 20 MHz and an ADCResolution of 4096 were used
```

4. Load the .mat file containing `IRFProb`, `Omega`, and `IRFTransform` in the third step of the [workflow routine](https://github.com/CreLox/FluorescenceLifetime/blob/master/Workflows/PhasorIntensityFiltersFLIMFitting.m). This workflow routine lays out all the steps in a typical data analysis: intensity thresholding (for localized fluorophores), [phasor plot-based pixel filtering](https://github.com/CreLox/FluorescenceLifetime#phasor-transform-and-autofluorescence-filtering), region exclusion (manual correction), and fitting (using the MATLAB nonlinear optimization function `fmincon`). Use `Run Section` to perform your analysis in a guided, step-by-step manner. To minimize $\chi^2$ (the correct way for the Poisson process but numerically problematic due to the low and noisy event counts at the two tails) during fitting, set `FittingOption = Fitting2` (for a 2-component exponential decay fit) or `FittingOption = Fitting1` (for a mono-exponential decay fit) in the fifth step. To minimize the Manhattan distance between the fitted curve and raw data (a practical way employed in our data analysis, which is further explained [here](https://github.com/CreLox/FluorescenceLifetime#a-note-on-the-multi-component-exponential-fit)), set `FittingOption = Fitting2S` (by default; for a 2-component exponential decay fit) or `FittingOption = Fitting1S` (for a mono-exponential decay fit) in the fifth step.

All fitting parameters are automatically saved into a .mat file and two associated plots (including an overlay of the raw FLIM data in black and the fitted curve in red, as well as a residual plot tiled together with a plot of the auto-correlation function of residuals) are also automatically saved as individual .fig files.

<p align="center">
  <img width="540" alt="image" src="https://user-images.githubusercontent.com/18239347/190866352-23d2456c-499a-4e07-8c68-df225fb36841.png"><br>
  Exemplary output figure 1: An overlay of the raw FLIM data in black and the fitted curve in red. The "microtime" refers to the interval between the arrival of a detected photon and its corresponding excitation pulse.
</p>
<br>
<p align="center">
  <img width="540" alt="image" src="https://user-images.githubusercontent.com/18239347/190866386-ca717548-c3dc-431b-8647-4dd84c1b4070.png"><br>
  Exemplary output figure 2: A residual plot tiled together with a plot of the auto-correlation function (ACF) of the residuals in the exemplary output figure 1 above.
</p>

## Principles

To demonstrate how fluorescence lifetime measurements can quantify the FRET efficiency, consider a large number of donor fluorophore molecules with a lifetime of $τ_0$. In the absence of acceptor fluorophores, the exponential decay $D_0$ of donor fluorescence after pulsed excitation at time zero is

$$D_0(t) = Ce^{-t/τ_0}.$$

The total donor fluorescence intensity is

$$S_0=\int_0^{+\infty} D_0(t)dt = Cτ_0,$$

wherein the pre-exponential factor $C$ (also commonly referred to as the "amplitude") is a constant determined by the total number and properties of fluorophores, as well as the imaging setup. Without altering any of these conditions, in the presence of acceptor fluorophores and FRET, the possibility that an excited fluorophore stays excited (has not relaxed to the ground state either through the fluorescence-emitting route or the FRET-quenching route) at time $t$ is

$$P=e^{-(1/τ_0 +1/τ')t}.$$

Here, $τ'$ ( $=(r/R_0)^6τ_0$, wherein $r$ is the distance between the donor and the acceptor dipoles and the Förster radius/Förster distance/critical transfer distance $R_0$ is a constant determined by the donor, the acceptor, etc.; see the derivation of equation 15.2.27 [here](https://chem.libretexts.org/Bookshelves/Physical_and_Theoretical_Chemistry_Textbook_Maps/Time_Dependent_Quantum_Mechanics_and_Spectroscopy_(Tokmakoff)/15%3A_Energy_and_Charge_Transfer/15.02%3A_Forster_Resonance_Energy_Transfer_(FRET))) is the time parameter of FRET (note: although an excited fluorophore can only relax through one route, the two stochastic processes – fluorescence-emitting and FRET-quenching – are independent). Therefore, in the presence of acceptor fluorophores and FRET, the new decay dynamics of the donor fluorescence are

$$D(t)=Ce^{-(1/τ_0 +1/τ')t}=Ce^{-(τ_0+τ')t/(τ_0 τ')},$$

The **effective lifetime** of the donor fluorophore (which can be measured through FLIM) becomes

$$τ=\frac{τ_0 τ'}{τ_0+τ'},$$

and the total donor fluorescence intensity becomes $S = Cτ$. Therefore, the FRET efficiency

$$\frac{S_0-S}{S_0}=\frac{τ_0-τ}{τ_0}(=\frac{1}{(r/R_0)^6+1}),$$

wherein $τ_0$ and $τ$ can be measured through FLIM. Because the fluorescence lifetime in the absence of quenching is an intrinsic property of a mature fluorescent protein under a certain temperature (see [section 9.4.5.1, Kafle, 2020](https://www.sciencedirect.com/science/article/pii/B9780128148662000099)), the equation above greatly simplifies the FRET efficiency measurement. This equation still applies even if the fluorescence decay must be fitted by a multi-component exponential decay, as long as the average fluorescence lifetime $\bar{\tau}$ weighted by the corresponding $C$ of each component is used (also see [a section below](https://github.com/CreLox/FluorescenceLifetime#a-note-on-the-multi-component-exponential-fit)).

Below is an exemplary FLIM experiment (performed by Dr. Ajit Joglekar) from the [reference study](https://github.com/CreLox/FluorescenceLifetime#how-to-cite-this-work) where a high FRET efficiency was observed. Here in the experimental group (red), the nuclear pore complex protein NUP50 is tandemly tagged by mNeonGreen and mScarlet-I. In the control group (black), NUP50 is only tagged by mNeonGreen. We can see that the lifetime of mNeonGreen in NUP50-mNeonGreen-mScarlet-I is greatly shortened compared to the lifetime of mNeonGreen in NUP50-mNeonGreen. This results from the highly efficient FRET between mNeonGreen (the donor fluorophore) and mScarlet-I (the acceptor fluorophore) that are closely linked. And by fitting the FLIM data with (multi-component) exponential decays, we can quantify the FRET efficiency using the equation above.

<p align="center">
  <img width="540" alt="image" src="https://user-images.githubusercontent.com/18239347/202163005-5f7f270e-eafe-4143-9196-f1799b821bc7.png"><br>
  The scatter plots show the mean FLIM data (PDF: the empirical distribution function of the photon arrival microtime relative to the corresponding excitation pulse) of mNeonGreen (red: NUP50-mNeonGreen-mScarlet-I; black: NUP50-mNeonGreen) and each error bar represents the standard deviation of each microtime bin (the number of cells $N = 3$ in each group). The plot is generated using <a href="https://github.com/CreLox/FluorescenceLifetime/blob/master/Workflows/FitFreeFLIMDataOverlay.m">this script</a> and the raw data from this FLIM experiment.
</p>

## Phasor transform and autofluorescence filtering
The phasor transform is a normalized Fourier transform that converts time-resolved emission data into a single point in the complex plane. For a donor fluorophore with an exponential decay $D(t) = Ce^{-t/τ}$ after pulsed excitation at time zero and any positive $\omega$ with a dimension of $s^{-1}$, the phasor transform of $D(t)$ is defined as

$$\mathcal{P}(\omega, D) = (\int_0^{+\infty} e^{i \omega t}D(t)dt)/(\int_0^{+\infty} D(t)dt) = \frac{1}{1+\omega^2\tau^2} + \frac{\omega\tau}{1+\omega^2\tau^2}i.$$

On the complex plane, the corresponding phasor $\frac{1}{1+\omega^2\tau^2} + \frac{\omega\tau}{1+\omega^2\tau^2}i$ is distributed on the **universal semicircle**

$$|z-1/2| = 1/2, \operatorname{Im}(z)>0.$$

For an ensemble of fluorophores with different exponential decay lifetimes, it is easy to derive that the phasor is a linear combination of the phasors of the composing species $\mathcal{P}(\omega, D_m), m = 1, 2, ..., M$, weighted by their corresponding **fractional intensity**:

$$\mathcal{P}(\omega, \sum_{m=0}^{M} D_m) = \sum_{m=0}^{M} (\mathcal{P}(\omega, D_m) \cdot C_m\tau_m / \sum_{l=0}^{M} C_l\tau_l ).$$

Since the fractional intensity $\in (0, 1]$, the phasor of the ensemble is always within the convex hull defined by the phasor(s) of all composing species and is therefore on or within the semicircle. The simplest case wherein the ensemble contains two species with various lifetimes is illustrated below. 

<p align="center">
  <img width="540" alt="image" src="https://user-images.githubusercontent.com/18239347/190550027-80257b25-4a5b-4318-9dbe-8da367782316.png">
</p>

Although there exists a one-to-one mapping relationship between one-component exponential decays $\in\\{e^{-t/\tau}\mid\tau\gt0\\}$ and points on the universal semicircle given a specific $\omega$ (because $\operatorname{tan}(\operatorname{arg}(\mathcal{P})) = \omega\tau$), a point inside the universal semicircle may correspond to various multi-component exponential decays with **different average lifetimes (weighted by the corresponding $C$ of each component)**. In fact, suppose that the blue fixed point $x_0 + y_0i, x_0, y_0 \in \mathbb{R}$ in the figure above represents the phasor transform of a two-component exponential decay with the two cyan points representing its two components and that the slope of the cyan line segment connecting the two cyan points is $k$ (variable). It is easy to derive that

$$\bar{\tau}(k) = \frac{(1-x_0)k+y_0}{\omega(y_0k+x_0)} \in (0, \frac{y_0}{\omega(x_0^2+y_0^2)}).$$

As a side note, Section 4.2 of [Ranjit, Malacrida, and Gratton, 2018](https://analyticalsciencejournals.onlinelibrary.wiley.com/doi/full/10.1002/jemt.23061) proposed a fit-free method (not implemented in this toolkit) to determine the lifetimes of the components of a two-component exponential decay. The key is to use various $\omega$ to perform the phasor transform. However, like the fitting method, it should be tested using real FLIM data (with limited event counts) and scrutinized from an error analysis perspective.

The actual FLIM signal

<p align="center">
$R(t) =$ the normalized IRF $I(t) \circledast$ the (multi-component) exponential decay $D(t)$ (+ noise).
</p>

If we ignore the noise, the phasor transform of the raw time-resolved emission data $R(t)$ is then

$$\mathcal{P}(\omega, R) = (\int_0^{+\infty} e^{i \omega t}R(t)dt)/(\int_0^{+\infty} R(t)dt),$$

wherein the denominator

$$\begin{align}\int_0^{+\infty} R(t)dt &= \int_{t=0}^{+\infty} (\int_{T=0}^{t} I(T)D(t-T)dT)dt = \int_{T=0}^{+\infty} I(T)(\int_{t=T}^{+\infty} D(t-T)dt)dT \newline &= \int_{T=0}^{+\infty} I(T)dT\cdot\int_{t=0}^{+\infty} D(t)dt = \int_{t=0}^{+\infty} D(t)dt\end{align}$$

and the numerator

$$\int_0^{+\infty} e^{i \omega t}R(t)dt = \int_0^{+\infty} e^{i \omega t}(I(t) \circledast D(t))dt = \int_0^{+\infty} e^{i \omega t}I(t)dt \cdot \int_0^{+\infty} e^{i \omega t}D(t)dt.$$

Therefore,

$$\mathcal{P}(\omega, D) = \mathcal{P}(\omega, R) / (\int_0^{+\infty} e^{i \omega t}I(t)dt).$$

The `calculateIRFTransform` [function](https://github.com/CreLox/FluorescenceLifetime/blob/master/calculateIRFTransform.m) calculates $\int_0^{+\infty} e^{i \omega t}I(t)dt$. For the actual discrete time-resolved emission data, suppose that the arrival micro-time (after pulsed excitation at time zero) of a series of emission photons $n, n = 1, 2, ..., N$, is $t_n$. The phasor transform of the series is then
$$\mathcal{P}(\omega) = \sum_{n=0}^{N} e^{i \omega t_n}/N.$$

A critical application of the phasor plot in the workflow is to identify pixels with mostly autofluorescence, without performing tedious fitting pixel by pixel. Autofluorescent substances in the green channel in mammalian organelles (mainly flavins; see [Aubin, 1979](https://journals.sagepub.com/doi/epdf/10.1177/27.1.220325)) typically feature shorter lifetimes (see [Horilova, Cunderlikova, and Chorvatova, 2014](https://www.spiedigitallibrary.org/journals/journal-of-biomedical-optics/volume-20/issue-05/051017/Time--and-spectrally-resolved-characteristics-of-flavin-fluorescence-in/10.1117/1.JBO.20.5.051017.full)) than the green fluorescent protein chosen for the FLIM experiment does. For example, in the [reference study](https://github.com/CreLox/FluorescenceLifetime#how-to-cite-this-work), we used mNeonGreen (with a [reported lifetime](https://www.nature.com/articles/nmeth.2413) of ~ 3 ns) and [mScarlet-I](https://www.nature.com/articles/nmeth.4074) as the donor and the acceptor fluorophores (based on [this research](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0219886)), respectively. Reflected on the phasor plot, the phasor transforms of time-resolved emission data registered to pixels with mostly autofluorescence are well separated from those registered to pixels with mostly fluorescent proteins.

## A note on the multi-component exponential fit

> ... Without careful consideration of the nature of the problem, deconvolution as an information-improving device can easily become an exercise in self-delusion. — [Knight and Selinger (1971)](https://www.sciencedirect.com/science/article/pii/0584853971800739)

The multi-component exponential fit is intrinsically flexible. Regarding this, [Grinvald and Steinberg (1974)](https://www.sciencedirect.com/science/article/pii/0003269774903121) raised two educational examples which are reproduced here:

<p align="center">
  <img width="810" alt="image" src="https://user-images.githubusercontent.com/18239347/184480647-87a58ad1-fc0d-4daf-a830-a7bf177ed668.png">
</p>

Therefore, **one should always be vigilant when translating the parameters derived from a multi-component exponential fit into actual physical parameters.** Regardless, the average lifetime of a **good** multi-component exponential fit weighted by the corresponding $C$ of each component should be conserved. This is because both $S$, the area underneath the decay curve which is optimally fitted by applying `FittingOption = Fitting1S` or `FittingOption = Fitting2S`, and $D(0)$, the fluorescence intensity at $t = 0$, are conserved for all **good** fits:

$$\bar{\tau} = \frac{\sum C_i \tau_i}{\sum C_i} = \frac{S}{D(0)}.$$

## Prepulse and afterpulse in the measured IRF
Our current protocol uses a mirror on the sample plane to measure the IRF. The emission filter is removed and internal reflection at lenses is observed as a prepulse in the measured IRF. This prepulse is an artifact due to the removal of the emission filter and should be manually removed in postprocessing. Additionally, the APD detector has an afterpulse feature (see [Ziarkash et al., 2018](https://www.nature.com/articles/s41598-018-23398-z)). This is intrinsic to the detector and an integral part of the IRF that should NOT be removed in postprocessing.

## Normalization of event counts
For a scanning microscope, the amplification factor is determined by the setup and the objective but not by the scale of the FOV set for scanning. Therefore, the power of the excitation light on the sample plane and the corresponding area on the sample plane of the APD detector are not affected by the FOV set for scanning. Because the pixel dwell time is fixed, the event count per **pixel** is directly comparable, regardless of the scale of the FOV set for scanning.

## How to cite this work?
This toolkit is licensed under Apache-2.0. If you have used any of the codes in your research, please kindly consider citing the following reference study:

Chen, C., Piano, V., Alex, A., Han, S.J.Y., Huis, P.J., Roy, B., Musacchio, A., and Joglekar, A.P., 2022. The structural flexibility of MAD1 facilitates the assembly of the mitotic checkpoint complex. bioRxiv: https://www.biorxiv.org/content/10.1101/2022.06.29.498198v1.full.

## Acknowledgments
I would like to thank [Dr. J. Damon Hoff](https://github.com/synkron) (from the SMART Center at the Univerisity of Michigan, Ann Arbor) for his suggestions on the manual and his ground-laying contributions to scripts for parsing raw data files.
