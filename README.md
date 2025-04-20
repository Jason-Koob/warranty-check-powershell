# warranty-check-powershell
A basic powershell script to read from CSV and retrieve serial numbers and call out to their manufacturers for their warranty status. 

## Process Breakdown
- [x] Create a readme for documentation
- [x] Write a list of commands and arguments for the script
- [x] Create a powershell script with optional arguments
  - [x] Create a process to find columns listing serial numbers
  - [x] Create a process to find columns listing manufacturers
  - [ ] Get API addresses for common manufacturers
    - [x] Lenovo
    - [ ] Dell
  - [x] For each device per manufacturer, request warranty status
  - [x] Parse responses from each response, while still implementing error checking and security
  - [x] Store the sanitized responses to a formatted csv
