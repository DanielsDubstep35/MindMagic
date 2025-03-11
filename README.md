# MindMagic
Cast spells, fight monsters, and avoid obstacles in VR with your Mind!
<p align="center">
  <img src="https://github.com/user-attachments/assets/8275c297-aad4-4a3c-a253-ef489cffb70e" alt="Mind Magic Development" />
</p>

## Tables of contents
* [Project Description](#project-description)
* [Project Challenges](#project-challenges)
* [Hardware Challenges](#hardware-challenges)
* [Software Challenges](#software-challenges)
* [Screenshots](#screenshots)

# Project Description

MindMagic is a Game made in Godot, in which you cast spells with your mind, and jump over obstacles in VR to reach the goal. 

Using an Electroencephalogram (or EEG), the users brainwave data was was read into a python script, that uses that data as input for a machine learning model that predicts the users emotions (however, it was very simple states, such as whether the user was relaxed or concentrated). 

This prediction from the machine learning model was then sent over a UDP port to the godot game engine, in which the data was read from the constant connection stream and decoded. Depending on what the user was thinking, the corresponding spell would be cast!

<p align="center">
 <img width="452" alt="image" src="https://github.com/user-attachments/assets/68ea8e7c-0189-4dee-99b2-965179216c5b" />
 <p align="center">A rough example of the technical architecture of Mind Magic</p>
</p>

# Project Challenges

This project was risky from the beginning. The main challenge for this project was acquiring an EEG, and figuring out how to make it work with a game client. The addition of Virtual Reality complicated this project even more, as whatever solution I created for the EEG needed to be compatible with a Virtual Reality headset as well.

# Hardware Challenges

EEGs are already expensive devices, and high end ones are usually very rare to get a hold of. The initial stages of this project assumed that an EEG would not be obtained. Instead, the project would use fake brain data to simulate what input from an EEG would look like. Therefore, the very first task in this project was to figure out how to either run python within Godot, or send python data to Godot. The final solution to this task ended up using a UDP server to send the fake data to Godot. This solution was not ideal, as it required that the user runs a python script before starting the game. This was a major limitation of the project, as it made the project less user friendly.

In order to make this project more interesting without an EEG, Virtual Reality was added. This created another unique challenge to this project. The python script that was sending the data to Godot instead had to send the data to the Virtual Reality headset. Fortunately, the Virtual Reality headset that was used was a Pico Neo 3 Pro, which shows its IP address whenever the user wants to screencast what they are seeing. This IP address was added to both the python script and the Godot game client, and this allowed the python script to send the data to the Virtual Reality headset. Some failed attempts to this solution included attempting to run and install python within the Virtual Reality headset. This was not possible, as Pico headsets are proprietary and do not allow the user to install any software on them without either jailbreaking them or using some kind of developer mode. 

When the Muse S headband was obtained, this project already had a lot of work done on it with Virtual Reality. This led to both the EEG and Virtual Reality headset being used together, which made this project more interesting and complex. However, Wearing the Muse S headband and the Virtual Reality headset was not comfortable, as the Pico Neo 3 Pro had to be in a specific position in order to not push the Muse S headband down. Apart from this, the Muse S headband had a  chance to disconnect from the computer, which would require the user to rerun the python script. Finally, the user needed to stay close to the computer, as the Muse S headband had a limited.

# Software Challenges

Before Virtual Reality was added to this project, the game would run the python script automatically when the game started. This relied on the os.execute() function in Godot, which is usually used to open applications through your game, but was used in this project to open and run both a python interpreter and the python script. The python script could then be quit by getting the parent threads PID and killing it. This solution was user-friendly, and also allowed for the game to connect to the EEG when the game started. However, this solution needed to be scrapped due to the inability for python to run within the Virtual Reality headset. Also, os.execute() was not guaranteed to work on the proprietary Pico Neo 3 Pro headset.

Calculating Neurofeedback metrics with the Muse S headband was also a challenge. Multiple machine learning models were tested with many different recordings of brain data, but the user did not have strong control over the output of the machine learning model. This could of been due to the user not being able to control their emotions in real time, or the machine learning model not being trained properly. Raw brain data was the worst of these tests, as the emotional state of the user looked almost random. This is the reason why Neurofeedback metrics were calculated and used instead of raw brain data. The Neurofeedback metrics were slightly more consistent, and the user had a little more control over them. However, the user still had to be in a specific emotional state in order to get the desired output from the machine learning model, which was still pretty challenging to achieve. Also, their was no way to know for certain if the user was actually in the desired emotional state, as the Muse S headband only has 4 electrodes, and more electrodes would be needed to get a more accurate reading of the brain.

# Screenshots

<p align="center">

<img src="https://github.com/user-attachments/assets/d6a4a35e-19ac-4f62-b2af-3d7fbe318c60" alt="Mind Magic Intro" />

![Level_1_8](https://github.com/user-attachments/assets/3ee7647c-d053-40b8-b556-3b9eda62cac3)
 
![Level_1_5](https://github.com/user-attachments/assets/11a93151-c60c-40e4-a4f3-3a1c30148cb5)

![Level_2_1](https://github.com/user-attachments/assets/89925c55-ad83-4351-9862-43f9e1bbd39f)

![Level_2_4](https://github.com/user-attachments/assets/266c6779-623d-4918-8879-014195d086bc)

![Level_3_3](https://github.com/user-attachments/assets/131b6119-01be-4798-b4d5-02cbff6b5653)

![Level_3_2](https://github.com/user-attachments/assets/44514c5c-bddb-45ed-b8fc-ec3474bf1170)
</p>
