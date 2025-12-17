; Cadence Virtuoso GUI with Two Tabs
; This creates a form with a tabbed interface

; Helper function to run external script and update status
procedure( runExternalScript(scriptPath statusField logField)
  let( (exitCode outputFile outputPath logText statusMsg timestamp)

    ; Create temporary file to capture script output
    outputPath = sprintf(nil "/tmp/virtuoso_script_output_%d.log" getCurrentTime())

    ; Clear the log field before starting
    logField->value = "Running script...\n"

    ; Add timestamp to log
    timestamp = getCurrentTime()
    logText = sprintf(nil "[%s] Running: %s\n" timeToString(timestamp) scriptPath)
    logField->value = strcat(logField->value logText)

    ; Run the external script and redirect output to temp file
    ; Use 2>&1 to capture both stdout and stderr
    exitCode = system(sprintf(nil "%s > %s 2>&1" scriptPath outputPath))

    ; Read the output file
    outputFile = infile(outputPath)
    if( outputFile then
      logText = ""
      while( gets(line outputFile)
        logText = strcat(logText line)
      )
      close(outputFile)

      ; Append script output to log field
      logField->value = strcat(logField->value "\n--- Script Output ---\n")
      logField->value = strcat(logField->value logText)
      logField->value = strcat(logField->value "\n--- End Output ---\n\n")
    else
      logField->value = strcat(logField->value "\nWarning: Could not read script output\n")
    )

    ; Check if script passed (exit code 0) or failed (non-zero)
    if( exitCode == 0 then
      statusMsg = "PASSED"
      logField->value = strcat(logField->value sprintf(nil "[%s] Result: PASSED\n" timeToString(getCurrentTime())))
    else
      statusMsg = sprintf(nil "FAILED (exit code: %d)" exitCode)
      logField->value = strcat(logField->value sprintf(nil "[%s] Result: FAILED (exit code: %d)\n" timeToString(getCurrentTime()) exitCode))
    )

    ; Update the status field
    statusField->value = statusMsg

    ; Clean up temporary file
    system(sprintf(nil "rm -f %s" outputPath))

    ; Return the exit code
    exitCode
  ) ; end let
) ; end procedure

procedure( createTwoTabGUI()
  let( (myForm tabField tab1Fields tab2Fields)

    ; Create the main form
    myForm = hiCreateAppForm(
      ?name 'myTabbedForm
      ?formTitle "Two Tab GUI"
      ?callback list("hiFormDone(hiGetCurrentForm())")
    )

    ; Define Tab 1 fields (Script Runner)
    tab1Fields = list(
      hiCreateLabel(
        ?name 'tab1Label
        ?labelText "Script Runner"
      )
      hiCreateStringField(
        ?name 'scriptPathField
        ?prompt "Script Path:"
        ?value ""
      )
      hiCreateButton(
        ?name 'runScriptButton
        ?buttonText "Run Script"
        ?callback "runExternalScript(hiGetCurrentForm()->scriptPathField->value hiGetCurrentForm()->statusField hiGetCurrentForm()->logField)"
      )
      hiCreateStringField(
        ?name 'statusField
        ?prompt "Status:"
        ?value "Not Run"
        ?editable nil
      )
      hiCreateLabel(
        ?name 'logLabel
        ?labelText "Script Output Log:"
      )
      hiCreateMLTextField(
        ?name 'logField
        ?value "No script has been run yet."
        ?editable nil
      )
      hiCreateButton(
        ?name 'clearLogButton
        ?buttonText "Clear Log"
        ?callback "hiGetCurrentForm()->logField->value = \"Log cleared.\n\""
      )
    )

    ; Define Tab 2 fields
    tab2Fields = list(
      hiCreateLabel(
        ?name 'tab2Label
        ?labelText "This is Tab 2"
      )
      hiCreateStringField(
        ?name 'tab2Field
        ?prompt "Enter value:"
        ?value ""
      )
      hiCreateButton(
        ?name 'tab2Button
        ?buttonText "Submit Tab 2"
        ?callback "println(\"Tab 2 button clicked!\")"
      )
    )

    ; Create the tab field with two tabs
    tabField = hiCreateTabField(
      ?name 'mainTabs
      ?choices list("Tab 1" "Tab 2")
      ?fields list(tab1Fields tab2Fields)
      ?parent myForm
    )

    ; Create OK and Cancel buttons at the bottom
    hiCreateButton(
      ?name 'okButton
      ?buttonText "OK"
      ?callback "hiFormDone(hiGetCurrentForm())"
      ?parent myForm
    )

    hiCreateButton(
      ?name 'cancelButton
      ?buttonText "Cancel"
      ?callback "hiFormCancel(hiGetCurrentForm())"
      ?parent myForm
    )

    ; Display the form
    hiDisplayForm(myForm)

    myForm
  ) ; end let
) ; end procedure

; Call the procedure to create and display the GUI
; Uncomment the line below to automatically launch the GUI when loading this file
; createTwoTabGUI()

; Instructions:
; 1. Load this file in Cadence Virtuoso: load("virtuoso_gui_tabs.il")
; 2. Run the command: createTwoTabGUI()
