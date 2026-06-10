/**
 * Runs the mutation coverage goal for PIT.
 */

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

void executeBashCommand(String bashCommand) {
    ProcessBuilder processBuilder = new ProcessBuilder("bash", "-c", bashCommand);
    try {
        Process process = processBuilder.start();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
            String line;
            while ((line = reader.readLine()) != null) {
                System.out.println(line);
            }
        }
        int exitCode = process.waitFor();
        System.out.println("Exited with code: " + exitCode);
    } catch (IOException e) {
        System.err.println("Failed to start process: " + e.getMessage());
    } catch (InterruptedException e) {
        System.err.println("Process was interrupted: " + e.getMessage());
        Thread.currentThread().interrupt();
    }
}

boolean hasArgument(String option, String[] args) {
	for (String arg : args) {
		if (arg.equals(option)) {
			return true;
		}
	}
	return false;
}

void runPlainPit() {
	executeBashCommand("mvn clean install");
	executeBashCommand("mvn org.pitest:pitest-maven:mutationCoverage");
	Path homePath = Paths.get(System.getProperty("user.home"));
	Path dataPath = homePath.resolve("data");
	Path currentPath = Paths.get(System.getProperty("user.dir"));
	Path projectPath = currentPath.getFileName();
	Path projectPitDataPath = dataPath.resolve("pit-reports").resolve(projectPath);
	System.out.println(projectPitDataPath);
	Path mavenTargetPath = currentPath.resolve("target");
	Path pitReportsPath = mavenTargetPath.resolve("pit-reports");
	try {
	    Files.createDirectories(projectPitDataPath);
	    Files.move(pitReportsPath, projectPitDataPath, StandardCopyOption.REPLACE_EXISTING);
	} catch (IOException ioe) {
		System.err.println("Failed IO operation: " + ioe.getMessage());
	}
}

void main(String[] args) {
	if (args.length == 0) {
		runPlainPit();
	} else {
        boolean tree = hasArgument("-t", args);
        System.out.println("Storing results in tree structure: " + tree);
	    if (hasArgument("-g", args)) {
			System.out.println("Running against Git Diff");
		} else {
			for (String arg : args) {
				if (!arg.startsWith("-")) {
					System.out.println("Running PIT on " + arg);
				}
			}
		}
	}
}