# Sharpen PITEST

This repository contains a little tool to sharpen your unit tests using [PITEST](https://pitest.org/). Check out my blog
article
[“How to Sharpen Your Unit Tests”](https://medium.com/compendium/how-to-sharpen-your-unit-tests-58ee01329f15) for a
broader description of what it means to “sharpen” your unit tests, and why you want to do thats.

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

* [Getting Started](#getting-started)
* [Overview](#overview)
  * [Running the Script](#running-the-script)
  * [Equivalent Mutations](#equivalent-mutations)
  * [Bulk Ignoring](#bulk-ignoring)
* [Generalization](#generalization)

## Getting Started

The scripts are written for Java development on a Linux machine with Ruby already installed. It assumes that you have a
directory called `bin` that's included in the your path, so you can execute the scripts anywhere from the command line.
In addition, the scripts assume that the PITEST reports can be stored in a directory parallell to the main directory of
your Java project, and that the parallell directory can be created by the script.

In order to deploy the scripts to your `~/bin` directory, run the following command in the main directory of a clone of
this repository:

```
./deploy.sh
```

Next, navigate to a Java project using PITEST and try to run the main script:

```
sharpen_pitest.rb
```

If you want to try it out on a project for which the script worked at some point in time, you can use my project
[TSVGJ](https://github.com/filipvanlaenen/tsvgj).

While the script is running, you should see the output from PITEST, at the end followed by output like this:

```
Defs                     :  4 /  4 (0, 100.0%)
G                        :  5 /  5 (0, 100.0%)
Line                     : 15 / 15 (0, 100.0%)
Path                     : 26 / 26 (0, 100.0%)
Text                     : 24 / 24 (0, 100.0%)
Transform                :  4 /  4 (0, 100.0%)
ArcToCommand             :  0 /  1 (1, 0.0%)
ClosePathCommand         :  0 /  1 (1, 0.0%)
ElementType              :  0 /  1 (1, 0.0%)
HexadecimalColorAttribute:  0 /  1 (1, 0.0%)
KeywordColorAttribute    :  0 /  1 (1, 0.0%)
LineToCommand            :  0 /  1 (1, 0.0%)
MoveToCommand            :  0 /  1 (1, 0.0%)
NumericArrayAttribute    :  0 /  1 (1, 0.0%)
NumericAttribute         :  0 /  1 (1, 0.0%)
Pattern                  : 16 / 17 (1, 94.1%)
ReferringAttribute       :  0 /  1 (1, 0.0%)
StringAttribute          :  0 /  1 (1, 0.0%)
Circle                   : 23 / 25 (2, 92.0%)
FontWeightValue          :  0 /  2 (2, 0.0%)
Rect                     : 19 / 21 (2, 90.5%)
Svg                      : 11 / 14 (3, 78.6%)
EnumerationAttribute     :  0 /  4 (4, 0.0%)
PathDefinition           :  0 /  4 (4, 0.0%)
Attributes               :  0 /  5 (5, 0.0%)
Elements                 :  0 /  6 (6, 0.0%)
```

I tend to put all my Git repositories in a directory called `~/git`. If you cloned TSVGJ in that directory, then the
source code is in `~/git/tsvgj`, and you'll find the PITEST reports in a directory called `~/git/tsvgj-pit-reports`.

Now, when I ran the report on TSVGJ, the overall mutation coverage was 99% (185 out of 187 mutations killed) for the
project. That's close to full coverage, but as the report above shows, even though the `Circle` class has full coverage
according to the regular PITEST report, when you run the `CircleTest` class in isolation, two of `Circle`'s mutations
are in fact not covered by `CircleTest`.

Does it matter? Yes, I think so. I like to be sure that when I make a mistake in a class like `Circle`, one of the unit
tests in `CircleTest` will fail and notify me that something's wrong in `Circle`. However, there are two mutations that
aren't covered by a unit test in `CircleTest`, but somewhere else. If I make a mistake related to those two mutations,
it's not a unit test in `CircleTest` that will start to fail, but a unit test in one of the other test classes. The
problem with that is the name of the failing test class will indicate the problem is somewhere else than in `Circle`,
and that I will have to dig through the problem to discover where the real problem is located. I like that when I make
a mistake in `Circle`, at least one unit test in `CircleTest` will start to fail.

Now, try to run the following command:

```
sharpen_pitest.rb -r
```

This time, the script doesn't run PITEST at all, it just aggregates the results from the already existing reports.

Try this:

```
sharpen_pitest.rb -r -s
```

This time, the result should be something like this:

```
ArcToCommand             :  0 /  1 (1, 0.0%)
ClosePathCommand         :  0 /  1 (1, 0.0%)
ElementType              :  0 /  1 (1, 0.0%)
HexadecimalColorAttribute:  0 /  1 (1, 0.0%)
KeywordColorAttribute    :  0 /  1 (1, 0.0%)
LineToCommand            :  0 /  1 (1, 0.0%)
MoveToCommand            :  0 /  1 (1, 0.0%)
NumericArrayAttribute    :  0 /  1 (1, 0.0%)
NumericAttribute         :  0 /  1 (1, 0.0%)
Pattern                  : 16 / 17 (1, 94.1%)
ReferringAttribute       :  0 /  1 (1, 0.0%)
StringAttribute          :  0 /  1 (1, 0.0%)
Circle                   : 23 / 25 (2, 92.0%)
FontWeightValue          :  0 /  2 (2, 0.0%)
Rect                     : 19 / 21 (2, 90.5%)
Svg                      : 11 / 14 (3, 78.6%)
EnumerationAttribute     :  0 /  4 (4, 0.0%)
PathDefinition           :  0 /  4 (4, 0.0%)
Attributes               :  0 /  5 (5, 0.0%)
Elements                 :  0 /  6 (6, 0.0%)
```

The option `-s` removes the classes with full coverage, so you can concentrate on what's hopefully a short list of
classes with surviving mutations.

Next, try this:

```
pitest CircleTest
```

This time, you should see the output from Maven running PITEST. However, this runs PITEST with all test classes turned
off except for `CircleTest`. The PITEST report is stored in a directory named
`~/git/tsvgj-pit-reports/CircleTest/YYYYMMDDHHMM`, with `YYYYMMDDHHMM` a time stamp for when you ran the script. Use
this command while adding more unit tests to `CirceTest` and verifying the mutation coverage of `Circle`.

If you have classes with mutations in parts of the code that can't or shouldn't be tested, you can add an ignore file
so they don't show up in the report. The name of the ignore file should be `pitest.ignore`, and it should contain lines
with class names and the number of mutations to ignore, separated by a colon (`:`). Below is an example of such a file:

```
Attributes:2
Elements:3
```

## Overview

### Running the Script

To get an help message with a basic explanation of all available options, use the option `-h` (or `--help`) as follows:

```
sharpen_pitest.rb -h
```

To produce and output a full report, run the script without any of the options:

```
sharpen_pitest.rb
```

If you only want to see the current report, use the option `-r` (or `--report-only`):

```
sharpen_pitest.rb -r
```

Classes that are fully covered can be filtered out from the report using the option `-s` (or `--survivors-only`):

```
sharpen_pitest.rb -r -s
```

The report can also be filtered by package, using the option `-p` (or `--package`) with a parameter like this:

```
sharpen_pitest.rb -r -p net.filipvanlaenen.kolektoj.hash
```

### Equivalent Mutations

### Bulk Ignoring

## Generalization

The scripts in this repository are explicitly written for Java development on Linux with PITEST as test coverage tool.
Porting the scripts to other operating systems should be easy – for iOS it may even work out of the box.

If you use another test coverage tool than PITEST, you will need to adapt the functionality to run the test coverage
tool and the functionality to extract information from the reports. Adapting to another build tool than Maven requires
a change in the `pitest` script, but should be rather easy. Finally, if you're using another programming language, you
will probably need to do all of the above.

Ideally, you wouldn't need the scripts in this repository though. I assume that most test coverage tools are able to
produce the same information, and probably in one run too. What I would like to see is that they update their reporting
from red/green for not covered/covered to red/amber/green for not covered/covered by unassociated test class/covered
by associated test class.
