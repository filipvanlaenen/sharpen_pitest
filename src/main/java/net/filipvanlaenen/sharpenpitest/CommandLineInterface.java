package net.filipvanlaenen.sharpenpitest;

/**
 * Class implementing a command line interface.
 */
public class CommandLineInterface {
	/**
	 * Private constructor to prevent instantiation of this utility class.
	 */
	private CommandLineInterface() {
	}

	/**
	 * The main entry point for the command line interface.
	 *
	 * @param args The arguments.
	 */
	public static void main(final String[] args) {
		if (args.length < 1) {
			printUsage();
			return;
		}
		Command.valueOf(args[0].toUpperCase()).execute(args);
	}

	/**
	 * Prints the usage to the command line.
	 */
	private static void printUsage() {
		System.out.println("Usage:");
		System.out.println("  pitest -g");
		System.out.println("  pitest <class-name>+");
	}

	/**
	 * Enumeration with the available commands.
	 */
	public enum Command {
		/**
		 * Command to run pitest.
		 */
		PITEST {
			@Override
			void execute(final String[] args) {
				// TODO
			}
		};

		/**
		 * Executes the command, passing the arguments from the command line.
		 *
		 * @param args The arguments from the command line.
		 */
		abstract void execute(String[] args);
	}
}
