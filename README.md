# CS-Delgun

## Features
- Toggle Delgun on/off with a command.
- Delete entities by shooting at them.

## Installation
1. Download the script and place it in your `resources` folder.
2. Add the following line to your `server.cfg`:
    ```
    ensure CS-Delgun

    ```

## Usage
- Use the command `/delgun` to toggle the Delgun on or off.
- Aim and shoot at an entity to delete it when the Delgun is active.

## Permissions
To restrict the use of the Delgun command to specific groups, you can use the ACE permissions system. Add the following line to your `server.cfg` to allow only the `admin` group to use the Delgun command:
```

    add_ace group.admin CS-Delgun allow