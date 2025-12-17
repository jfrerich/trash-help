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
  let( (myForm tabWidget tab1 tab2 mainLayout scriptPathField statusField logField)

    ; Create the main form
    myForm = hiCreateAppForm(
      ?name 'myTabbedForm
      ?formTitle "Two Tab GUI"
      ?callback list("hiFormDone(hiGetCurrentForm())")
    )

    ; Create the tab widget
    tabWidget = hiCreateTabWidget(
      ?name 'mainTabs
      ?parent myForm
    )

    ; Create Tab 1
    tab1 = hiCreateTab(
      ?name 'tab1
      ?label "Tab 1"
      ?parent tabWidget
    )

    ; Add content to Tab 1
    hiCreateLabel(
      ?name 'tab1Label
      ?labelText "This is Tab 1"
      ?parent tab1
    )

    ; Field to enter script path
    scriptPathField = hiCreateStringField(
      ?name 'scriptPathField
      ?prompt "Script Path:"
      ?value ""
      ?parent tab1
    )

    ; Button to run the external script
    hiCreateButton(
      ?name 'runScriptButton
      ?buttonText "Run Script"
      ?callback "runExternalScript(hiGetCurrentForm()->scriptPathField->value hiGetCurrentForm()->statusField hiGetCurrentForm()->logField)"
      ?parent tab1
    )

    ; Status field to show PASS/FAIL
    statusField = hiCreateStringField(
      ?name 'statusField
      ?prompt "Status:"
      ?value "Not Run"
      ?editable nil
      ?parent tab1
    )

    hiCreateLabel(
      ?name 'logLabel
      ?labelText "Script Output Log:"
      ?parent tab1
    )

    ; Multi-line text field for script output log
    logField = hiCreateMLTextField(
      ?name 'logField
      ?value "No script has been run yet."
      ?editable nil
      ?rows 15
      ?columns 80
      ?parent tab1
    )

    ; Button to clear the log
    hiCreateButton(
      ?name 'clearLogButton
      ?buttonText "Clear Log"
      ?callback "hiGetCurrentForm()->logField->value = \"Log cleared.\n\""
      ?parent tab1
    )

    ; Create Tab 2
    tab2 = hiCreateTab(
      ?name 'tab2
      ?label "Tab 2"
      ?parent tabWidget
    )

    ; Add content to Tab 2
    hiCreateLabel(
      ?name 'tab2Label
      ?labelText "This is Tab 2"
      ?parent tab2
    )

    hiCreateStringField(
      ?name 'tab2Field
      ?prompt "Enter value:"
      ?value ""
      ?parent tab2
    )

    hiCreateButton(
      ?name 'tab2Button
      ?buttonText "Submit Tab 2"
      ?callback "println(\"Tab 2 button clicked!\")"
      ?parent tab2
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
