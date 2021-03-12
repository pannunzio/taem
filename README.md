# "The Artificial Empathy Machine"
> “What Masques, What Dances Shall We Have”
> Theseus, Midsummer Night's Dream, [V, 1]

## Thesis Project for RTA New Media courses 82A and B

### Description:
Can a human love a machine? Can there be empathy when communication is limited?
Project explores empathy and conversation through conversing in film clips.

Main tools: Processing and Python

Installation Requirements and technical info at the end

### Artist Statement:

The greatest disservice anyone can do to art is to presume it to be a visual creation rather than an experience. And the greatest disservice to anything at all is to use beauty instead of meaning as a unit of measurement. When meaning is used as a tool to quantify an experience then there is suddenly an opportunity to learn and to be connected with something beyond the self. This project is art in its most abstract form: an exploration of meaning as a tool to calculate what is behind human connections and what constitutes empathy. It is a project that attempts to make sense of what is already obvious but cannot be explained.

I make art that explores human connection because empathy is the single most fascinating aspect of human behavior. Empathy is the reason why people can agree and disagree, it is the pillar of society, of understanding and compassion. Without empathy, there is no meaningful connection created and therefore no art to be experienced. I explore humanity across a variety of media and look for the hidden algorithms of empathy in daily life. It is a constant exploration of the effects of human connection and lack thereof. My art is autobiographical in the sense that it documents what I see in life and what I take away from it and builds upon that understanding. 

The ability to communicate with each other should not be taken for granted. There are complex rules that determine whether or not an individual will be heard and understood. In order to create meaningful connections, we must establish an understanding of the barriers that prevent empathy from happening. Thus, it is important to be able to assess the needs of every party involved in a moment of communication. Social structures, no matter how complex, can be broken down to a series of components and instructions that our brains (powerful biochemical computers) interpret and assess in order to determine the next course of action for each individual. So the question remains, can an electromechanical computer do the same? If algorithms of empathy can be deconstructed and reused, then it is possible to create artificial empathy to forge meaningful connections between human and art. 

This is the governing principle of my work.

### Code Setup:

#### Software requirements:
  * JVM
  * Python3
  * Processing3
  * MySQL
  * For Mac users, xcode coding~~bullshit~~ command lines toolkit

#### Installing python dependencies with pip3 (because I use python3. use regular pip at your own discretion but let me know how that goes)

  ```
    brew install portaudio
    pip3 install python-osc
    pip3 install pyttsx3
    pip3 install SpeechRecognition
    pip3 install PyAudio
    pip3 install pymysql
  ```
#### Processing Libraries required:
  ```
   processing.video.*
   netP5.*;
   oscP5.*;
   java.sql.*;
 ```

**Disclaimer:** Some issues I encounter in this project are mac specific apparently. Let me know if something doesn't happen on other OS's and I'll add multiplatform to a future TO-Do list
