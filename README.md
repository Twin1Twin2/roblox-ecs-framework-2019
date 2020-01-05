# Notes/Postmortem/Brain Dump
- This was an attempt to sync components and their data between server and client.
- Like previous versions, one of the main goals of the framework was ease of use.
  - Entities are classes that hold their components instead of a UID
  - To make it easy for game designers to add/edit components by using ValueObjects inside of the Instance
- I used SpatialOS as inspiration for how the data can be synced (READ_ONLY, READ_WRITE, SERVER_ONLY)
- I did not want to use CollectionService as a means of syncing components with entities or defining components in entities.
- Attributes are the future and should make it easier to sync components
- Overall, I think I've made it too convoluted to sync components and lost interests over the difficulties in having to deal with them.
