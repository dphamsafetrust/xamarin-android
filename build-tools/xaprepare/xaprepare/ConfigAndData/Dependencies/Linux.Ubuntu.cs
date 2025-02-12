using System;
using System.Collections.Generic;

namespace Xamarin.Android.Prepare
{
	class LinuxUbuntu : LinuxUbuntuCommon
	{
		static readonly List<DebianLinuxProgram> preCosmicPackages = new List<DebianLinuxProgram> {
			new DebianLinuxProgram ("libx32tinfo-dev"),
		};

		static readonly List<DebianLinuxProgram> cosmicPackages = new List<DebianLinuxProgram> {
			new DebianLinuxProgram ("libx32ncurses6-dev"),
		};

		static readonly List<DebianLinuxProgram> preDiscoPackages = new List<DebianLinuxProgram> {
			new DebianLinuxProgram ("openjdk-8-jdk"),
		};

		protected Version UbuntuRelease { get; private set; } = new Version (0, 0);

		protected override bool NeedLibtool => (UbuntuRelease.Major == 17 && UbuntuRelease.Minor == 10) | UbuntuRelease.Major >= 18;

		public LinuxUbuntu (Context context) : base (context)
		{}

		protected override void InitializeDependencies ()
		{
			base.InitializeDependencies ();

			if (UbuntuRelease.Major < 18 || (UbuntuRelease.Major == 18 && UbuntuRelease.Minor < 10))
				Dependencies.AddRange (preCosmicPackages);
			else {
				if (UbuntuRelease.Major < 20)
					Dependencies.AddRange (cosmicPackages);
				if (UbuntuRelease.Major < 19)
					Dependencies.AddRange (preDiscoPackages);
			}
		}

		protected override bool EnsureVersionInformation (Context context)
		{
			Version ubuntuRelease;
			if (!Version.TryParse (Release, out ubuntuRelease)) {
				if (Int32.TryParse (Release, out int singleNumberVersion)) {
					ubuntuRelease = new Version (singleNumberVersion, 0);
				} else {
					Log.ErrorLine ($"Unable to parse string '{Release}' as a valid {Name} release version");
					return false;
				}
			}
			UbuntuRelease = ubuntuRelease;

			return true;
		}
	};
}
