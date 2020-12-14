
## UNIX

As is stated in the course prerequisites at the [announcement web page](https://www.sib.swiss/training/course/2020-11-NGS6). We expect participants to have a basic understanding of working with the command line on UNIX-based systems. If you don't have experience with UNIX command line, or if you're unsure whether you meet the prerequisites, follow our [online UNIX tutorial](https://edu.sib.swiss/pluginfile.php/2878/mod_resource/content/4/couselab-html/content.html).

## Software

We will be mainly working on an Amazon Web Services ([AWS](https://aws.amazon.com/]))  Elastic Cloud (EC2) server or, if you're not enrolled in the course in a Docker container. The AWS server behaves like a 'normal' remote server, and can be approached through `ssh` with a username, key and IP address. All participants will be granted access to a personal home directory.

Before the course, make sure you can comfortably work on a remote server. This means that you can approach it through the shell, modify scripts and transfer files. We can recommend `atom` for Linux and Mac, and `Notepad ++` in combination with MobaXterm for Windows. We will be visualising our results with IGV. Therefore, install in your computer (choose **Docker** if you are doing this course independently):

=== "mac OS/Linux"
    * SSH and scripting: [Atom](https://atom.io/) with packages like: [`terminus`](https://atom.io/packages/terminus) and [`ftp-remote-edit`](https://atom.io/packages/ftp-remote-edit)
    * Transferring files: [FileZilla](https://filezilla-project.org/)
    * [Integrative Genomics Viewer (IGV)](http://software.broadinstitute.org/software/igv/)

=== "Windows"
    * SSH and scripting: [MobaXterm](https://mobaxterm.mobatek.net/ "get MobaXterm") and/or [Notepad++](https://notepad-plus-plus.org/downloads/) with the plugin `NppFTP`
    * Transferring files: [FileZilla](https://filezilla-project.org/)
    * [Integrative Genomics Viewer (IGV)](http://software.broadinstitute.org/software/igv/)

=== "Docker"
    * [Docker](https://docs.docker.com/get-docker/)
    * A script editor [Atom](https://atom.io/) or [Notepad++](https://notepad-plus-plus.org/downloads/)
