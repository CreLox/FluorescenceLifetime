## Knowledgebase on FC(C)S/FLIM
[PicoQuant knowledgebase](https://www.picoquant.com/scientific/technical-and-application-notes/category/technical_notes_techniques_and_methods/P8)

## Prerequisite
This toolkit requires another repository of mine, [readHeader](https://github.com/CreLox/readHeader), to run.

## Principles
At long last, GitHub Markdown now supports [math expressions](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/writing-mathematical-expressions) (from May 2022)!

To demonstrate how fluorescence lifetime measurements can quantify the FRET efficiency, consider a large number of donor fluorophore molecules with a lifetime of $τ_0$. In the absence of acceptor fluorophores, the exponential decay $D_0$ of donor fluorescence after pulsed excitation at time zero is 
$$D_0(t) = Ce^{-t/τ_0}.$$
The total donor fluorescence signal (which can be measured through FLIM) is
$$S_0=\int_0^{+\infty} D_0(t)dt = Cτ_0,$$
wherein $C$ is a constant determined by the total number and properties of fluorophores, as well as the imaging setup. Without altering any of these conditions, in the presence of acceptor fluorophores and FRET, the possibility that an excited fluorophore stays excited (has not relaxed to the ground state either through the fluorescence-emiting route or the FRET-quenching route) at time $t$ is
$$P=e^{-(1/τ_0 +1/τ')t},$$
wherein $τ'$ is the time parameter of FRET (although an excited fluorophore can only relax through one route, the two stochastic processes – fluorescence-emitting and FRET-quenching – are independent). Therefore, in the presence of acceptor fluorophores and FRET, the new decay dynamics $D$ of donor fluorescence becomes 
$$D(t)=Ce^{-(1/τ_0 +1/τ')t}=Ce^{-(τ_0+τ')t/(τ_0 τ')},$$
The **effective lifetime** of the donor fluorophore (which can be measured through FLIM) becomes 
$$τ=\frac{τ_0 τ'}{τ_0+τ'},$$
and the total donor fluorescence signal becomes $S = Cτ$. Therefore, the FRET efficiency
$$\frac{S_0-S}{S_0}=\frac{τ_0-τ}{τ_0}.$$
Because the fluorescence lifetime in the absence of quenching is an intrinsic property of a mature fluorescent protein under a certain temperature (see [section 9.4.5.1, Kafle, 2020](https://www.sciencedirect.com/science/article/pii/B9780128148662000099)), the equation above greatly simplifies the FRET efficiency measurement. This equation still applies even if the fluorescence decay must be fitted by a multi-component exponential decay, as long as the fluorescence lifetime is an average value weighted by the corresponding $C$ of each component. 

## A note on deconvolution
As Knight and Selinger (1970) put it,
> ... Without careful consideration of the nature of the problem, deconvolutlon as an information-improving device can easily become an exercise in self-delusion.

Regarding this, [Grinvald and SteinBerg (1974)](https://www.sciencedirect.com/science/article/pii/0003269774903121) raised two very educational examples which illustrate the intrinsic flexibility of a multi-component exponential fit and are reproduced here:
<img width="810" alt="image" src="https://user-images.githubusercontent.com/18239347/184480647-87a58ad1-fc0d-4daf-a830-a7bf177ed668.png">

However, the average lifetime of a multi-component exponential fit weighted by the corresponding $C$ of each component (see the section above) should be conserved:
$$\bar{\tau} = \frac{\sum C_i \tau_i}{\sum C_i} = \frac{S}{D(0)}.$$

## General workflow

## Prepulse and afterpulse in the measured instrument response function (IRF)
Our current protocol uses a mirror on the sample plane to measure the IRF. The emission filter is removed and internal reflection at lenses is observed as a prepulse in the measured IRF. This prepulse is an artifact due to the removal of the emission filter and should be manually removed in postprocessing. Additionally, the avalanche photodiode (APD) detector has an afterpulse feature (see, for example, [Ziarkash et al., 2018](https://www.nature.com/articles/s41598-018-23398-z)). This is intrinsic to the detector and an integral part of the IRF that should NOT be removed in postprocessing.

## Normalization of event counts
Alba is a laser scanning microscopy setup. The amplification factor is determined by the setup and the objective but not by the scale of the FOV appointed for scanning. Therefore, the power of the excitation light on the sample plane and the corresponding area on the sample plane of the APD detector are not affected by the FOV appointed for scanning. Because the pixel dwell time is fixed, the event count per **pixel** is directly comparable, regardless of the scale of the FOV appointed for scanning.

## Acknowledgements
I would like to thank Dr. Damon Hoff (from the SMART Center at the Univerisity of Michigan, Ann Arbor) for his suggestions on the operations manual and his ground-laying contributions to scripts related to the I/O of data files.
