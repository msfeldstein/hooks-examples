#!/bin/bash

# Hook that prevents continuation by returning {continue: false}
echo '{"continue": false, "user_message": "API Key detected", "agent_message": "Continuation is not allowed"}'


