# Sharpen PITEST

This repository contains a little tool to sharpen your unit tests using [PITEST](https://pitest.org/).

The basic idea is as follows: when I have a class `A`, I want to make sure that all the mutations in `A` are killed by
unit tests in test class `ATest`. This ensures that test class `ATest` tests class `A` completely, as it is supposed to
do. However, the reports that follow with PITEST don't allow you to verify that the all the mutations in class `A` were
killed by unit tests in test class `ATest`. Some of them may actually have been killed by a unit test in test class
`BTest`, which tests class `B` using some functionality in class `A`.

The scripts in this repository do two main things:
- First, they run a regular round of PITEST, in order to discover all classes with mutations.
- Then, for each class `M` with mutations, they run PITEST, but with all other test classes than `MTest` turned off.
In addition to that, there is some logic to aggregate and present the results, and a couple of options that I found
useful to use the scripts effeciently.
