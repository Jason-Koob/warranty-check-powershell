# warranty-check-powershell
A basic powershell script to read from CSV and retrieve serial numbers and call out to their manufacturers for their warranty status. 

## Process Breakdown
- [ ] Create a readme for documentation
- [ ] Write a list of commands and arguments for the script
- [ ] Create a powershell script with optional arguments
  - [ ] Create a process to find columns listing serial numbers
  - [ ] Create a process to find columns listing manufacturers
  - [ ] Get API addresses for common manufacturers with fault tolerance
  - [ ] For each device per manufacturer, request warranty status
  - [ ] Parse responses from each response, while still implementing error checking and security
  - [ ] Store the sanitized responses to a formatted csv
