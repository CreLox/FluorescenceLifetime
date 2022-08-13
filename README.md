## Knowledgebase on FC(C)S/FLIM
[PicoQuant knowledgebase](https://www.picoquant.com/scientific/technical-and-application-notes/category/technical_notes_techniques_and_methods/P8)

## Prerequisite
This toolkit requires another repository of mine, [readHeader](https://github.com/CreLox/readHeader), to run.

## Principles
(At long last, GitHub Markdown now supports [math expressions](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/writing-mathematical-expressions)!)

## General workflow

## "Deconvolution"
As Knight and Selinger (1970) put it,
> ... Without careful consideration of the nature of the problem, deconvolutlon as an information-improving device can easily become an exercise in self-delusion.

## Prepulse and afterpulse in the measured instrument response function (IRF)
Our current protocol uses a mirror on the sample plane to measure the IRF. The emission filter is removed and internal reflection at lenses is observed as a prepulse in the measured IRF. This prepulse is an artifact due to the removal of the emission filter and should be manually removed in postprocessing. Additionally, the avalanche photodiode (APD) detector has an afterpulse feature (see, for example, [Ziarkash et al., 2018](https://www.nature.com/articles/s41598-018-23398-z)). This is intrinsic to the detector and an integral part of the IRF that should NOT be removed in postprocessing.

## Normalization of event counts
Alba is a laser scanning microscopy setup. The amplification factor is determined by the setup and the objective but not by the scale of the FOV appointed for scanning. Therefore, the power of the excitation light on the sample plane and the corresponding area on the sample plane of the APD detector are not affected by the FOV appointed for scanning. Because the pixel dwell time is fixed, the event count per **pixel** is directly comparable, regardless of the scale of the FOV appointed for scanning.

## Acknowledgements
I would like to thank Dr. Damon Hoff (from the SMART Center at the Univerisity of Michigan, Ann Arbor) for his suggestions on the operations manual and his ground-laying contributions to scripts related to the I/O of data files.
