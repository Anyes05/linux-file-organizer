# Linux File Analyzer Script

Academic project developed for the course **Administración de Infraestructuras**.

## Description

Bash script designed to analyze files and directories using Linux commands and parameter handling.

The script uses `ls` as the information source and allows listing:

* Specific file information
* Largest files in a directory
* Smallest files in a directory
* Executable files only
* Combined filters and parameter validation

## Features

### File Information (`-s`)

Displays detailed information about a file:

* Name
* Size
* Owner
* Permissions

Example:

```bash
./AI_2024_list.sh -s archivo.txt
```

---

### Largest Files (`-g`)

Lists the 3 largest files in a directory.

Example:

```bash
./AI_2024_list.sh -g
./AI_2024_list.sh -g /home/user/folder
```

---

### Smallest Files (`-p`)

Lists the 3 smallest files in a directory.

Example:

```bash
./AI_2024_list.sh -p
```

---

### Executable Files (`-x`)

Filters executable files only.

Can be combined with:

* `-g`
* `-p`

Example:

```bash
./AI_2024_list.sh -x -g
```

## Technologies Used

* Bash
* Linux
* Shell scripting
* Linux permissions and file management

## Concepts Applied

* Parameter validation
* Conditional structures
* File handling
* Linux permissions
* Command output processing
* Shell scripting best practices

## Project Structure

```txt
AI_2024_list.sh
README.md
```

## How to Run

Give execution permissions:

```bash
chmod +x AI_2024_list.sh
```

Run the script:

```bash
./AI_2024_list.sh
```

## Academic Context

Project developed during the 4th semester of the Tecnólogo en Informática program.
