Hi Jessica,

I'm submitting code for my D2L milestone bc why not?

link to video i submitted:
https://drive.google.com/file/d/1OtuDn3oIBRUZmh9DKRd2rtWqNvIWMBu5/view?usp=sharing

Here's what's happening:
  the processing sketch SelectAClip.pde is in charge of controlling the clip selection for now
  listenForSpeech.py just listens for speech and sends them to processing via OSC

  the communication between the py code and the processing sketch is currently commented out and processing sketch just chooses random clips to play from the list.

  things you'd need to get installed for this all to run:
    PyAudio
    portaudio [not specifically a python thing but important]
    speech_recognition
    pyttsx3
    pythonosc

What I'm still troubleshooting:
  synchronizing both programs and figuring out how to coordinate calls for input monitoring
  aka: the conversation between who is selecting and playing the clips (mouth) and who is monitoring the audience (the ears)
  perhaps i might look into neurology for inspiration. Will sleep on it a bit though.
  Please also give me ideas on this.

For next week:
  - hand in flowchart of decision-making and early design of state-machine
  - give the program a dictionary for reference
  - brainstorm how to go about categorizing words into feelings and needs.
  - ask you for help --help?

Main goal for the following week:
  - begin implementation of decision making algorithms
  - next step: begin adding the "eyes" --separate sketch monitoring human presence.
  - Getting the kinect in the equation and set up. Research if possible to combine PoseNet and the kinect.
