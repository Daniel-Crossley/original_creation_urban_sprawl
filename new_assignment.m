R = 400;          % number of rows
C = 400;          % number of columns

grid = zeros(R,C);
grid_colour = zeros(R,C);
neighbouring_resource = zeros(R,C);
resource_type = zeros(R, C);

spawn = false(200,200); %setting spawn matrix
spawn(:,:) = rand(200,200) < 0.2; %randomising spawnpoint

grid(101:300,101:300) = spawn;
next_grid = grid;

% Resource 1
placement_x = randi(R,1,2);
placement_y = randi(C,1,2);

grid(placement_x(1),placement_y(1)) = 3;
resource_type(placement_x(1), placement_y(1)) = 1;

% Resource 2
grid(placement_x(2),placement_y(2)) = 3;
resource_type(placement_x(2), placement_y(2)) = 2;

% Resource 3
grid(200,200) = 3;
resource_type(200, 200) = 3;
next_resource_type = resource_type;

resource_grid = zeros(R,C);

resource_grid(placement_x(1),placement_y(1)) = 100000;
resource_grid(placement_x(2),placement_y(2)) = 100000;
resource_grid(200,200) = 100000;

next_resource_grid = resource_grid;

live_neighbours = zeros(R,C);
resource_neighbours = zeros(R,C);

north = [R 1:R-1];     % indices of north neighbour
east  = [2:C 1];       % indices of east neighbour
south = [2:R 1];       % indices of south neighbour
west  = [C 1:C-1];

% Show the initial frame in the animation
set(figure, 'Visible', 'on', 'Position', get(0,'Screensize'))
set(gcf, 'KeyPressFcn', @KeyPressed) % this allows us to react to any key pressed in the figure window
handle = imagesc(grid); % save the handle for when we want to update the image later
title('Press any key to finish')
drawnow

%-----------------------------------
% Define the fixed number of time steps
num_steps = 100; % Adjust this value as needed

%% Simulation 
% Initialize variables for counting and area
time_steps = zeros(1, num_steps);
green_counts = zeros(1, num_steps);
green_areas = zeros(1, num_steps);
done = false;
step = 1;
%--------------------------------------------
while ~done && step <= num_steps% See comments at the bottom of this file for an explanation of this "while" loop.
            % For now, simply read this literally as saying we should take another step "while not done"

    live_neighbours = (grid(north, :) == 1) + (grid(north, west) == 1) + (grid(north, east) == 1) + (grid(:, west) == 1) + (grid(:, east) == 1) + (grid(south, west) == 1) + (grid(south, :) == 1) + (grid(south, east) == 1);
    resource_neighbours = (grid(north, :) > 1) + (grid(north, west) > 1) + (grid(north, east) > 1) + (grid(:, west) > 1) + (grid(:, east) > 1) + (grid(south, west) > 1) + (grid(south, :) > 1) + (grid(south, east) > 1);        
    live_resource_neighbours = (grid(north, :) == 2) + (grid(north, west) == 2) + (grid(north, east) == 2) + (grid(:, west) == 2) + (grid(:, east) == 2) + (grid(south, west) == 2) + (grid(south, :) == 2) + (grid(south, east) == 2);

    neighbouring_resource_one = (resource_type(north, :) == 1) + (resource_type(north, west) == 1) + (resource_type(north, east) == 1) + (resource_type(:, west) == 1) + (resource_type(:, east) == 1) + (resource_type(south, west) == 1) + (resource_type(south, :) == 1) + (resource_type(south, east) == 1);
    neighbouring_resource_two = (resource_type(north, :) == 2) + (resource_type(north, west) == 2) + (resource_type(north, east) == 2) + (resource_type(:, west) == 2) + (resource_type(:, east) == 2) + (resource_type(south, west) == 2) + (resource_type(south, :) == 2) + (resource_type(south, east) == 2);
    neighbouring_resource_three = (resource_type(north, :) == 3) + (resource_type(north, west) == 3) + (resource_type(north, east) == 3) + (resource_type(:, west) == 3) + (resource_type(:, east) == 3) + (resource_type(south, west) == 3) + (resource_type(south, :) == 3) + (resource_type(south, east) == 3);

    for i=2:R-1
        for j=2:C-1
            % Count live neighbours, count types of neighbours in Moore region
            % If the cell is live, standard ruleset
            
            
            % Neighbouring resource cell rules
            if (grid(i,j) == 2)
                if resource_type(i,j) == 0 % If no resource type, run standard game of life
                    next_grid(i,j) = 1;
                    resource_neighbours = (next_grid(north, :) > 1) + (next_grid(north, west) > 1) + (next_grid(north, east) > 1) + (next_grid(:, west) > 1) + (next_grid(:, east) > 1) + (next_grid(south, west) > 1) + (next_grid(south, :) > 1) + (next_grid(south, east) > 1);        
                    %new_neighbours = (next_grid(north, :) == 1) + (next_grid(north, west) == 1) + (next_grid(north, east) == 1) + (next_grid(:, west) == 1) + (next_grid(:, east) == 1) + (next_grid(south, west) == 1) + (next_grid(south, :) == 1) + (next_grid(south, east) == 1);
                %    if live_neighbours(i,j) == 3 || live_neighbours(i,j) == 2
                %        next_grid(i,j) = 1;
                %    else
                %        next_grid(i,j) = 0;
                %    end
                else % There is a resource neighbour - becomes a resource neigbour itself
                    next_grid(i,j) = 2;
                end
            
            % Dead cell rules
            elseif (grid(i,j) == 0)
                if live_neighbours(i,j) == 3
                    next_grid(i,j) = 1;
                else
                    next_grid(i,j) = 0;
                end
            

            % Resource rules
            elseif grid(i,j) == 1
                if resource_neighbours(i,j) == 0
                    if live_neighbours(i,j) == 3 || live_neighbours(i,j) == 2
                        next_grid(i, j) = 1;
                    else
                        next_grid(i, j) = 0;
                    end
                else
                    next_grid(i,j) = 2;
                    if neighbouring_resource_one(i,j) > 0
                        next_resource_type(i,j) = 1;
                    elseif neighbouring_resource_two(i,j) > 0
                        next_resource_type(i,j) = 2;
                    else
                        next_resource_type(i,j) = 3;
                    end

                    neighbouring_resource(i,j) = 1;
                end
            
            % Resource rules
            elseif grid(i,j) == 3
                if resource_grid(i,j) < 0
                    next_grid(i,j) = 0;
                    if resource_type(i,j) == 1
                        next_resource_type(next_resource_type == 1) = 0;
                        next_grid(next_resource_type == 1) = 1;
                    elseif resource_type(i,j) == 2
                        next_resource_type(next_resource_type == 2) = 0;
                        next_grid(next_resource_type == 2) = 1;
                    else
                        next_resource_type(next_resource_type == 3) = 0;
                        next_grid(next_resource_type == 3) = 1;
                    end
                else
                    if resource_type(i,j) == 1
                        next_resource_grid(i,j) = resource_grid(i,j) - sum(resource_type(:) == 1);% number of touching cells
                    elseif resource_type(i,j) == 2
                        next_resource_grid(i,j) = resource_grid(i,j) - sum(resource_type(:) == 2);% number of touching cells
                    else
                        next_resource_grid(i,j) = resource_grid(i,j) - sum(resource_type(:) == 3);% number of touching cells
                    end
                    next_grid(i,j) = 3;
                end
            end
                
    
            % Else if cell is resource, other ruleset
            % Else if cell is live and touching resource
            % Else cell is dead; standard ruleset
        end
    end
    
    grid = next_grid;

    % Make sure that grid colours don't change when resources run out
    grid_colour(grid == 0) = 0;
    grid_colour(grid == 1) = 1;
    grid_colour(grid == 2) = 2;
    grid_colour(grid == 3) = 3;

    resource_grid = next_resource_grid;
    resource_type = next_resource_type;
    imagesc(grid_colour); % this has the same effect as the line above, but is slower
    drawnow
    
    % -----------plotting area----------------

    % Make sure that grid colours don't change when resources run out
    grid_colour(grid == 0) = 0;
    grid_colour(grid == 1) = 1;
    grid_colour(grid == 2) = 2;
    grid_colour(grid == 3) = 3;

    resource_grid = next_resource_grid;
    resource_type = next_resource_type;
    imagesc(grid_colour);
    drawnow
    
    % Calculate and graph area/count of green pixels
    green_count = sum(grid(:) == 1);
    green_area = green_count / (R * C);
    
    % Store count and area at each time step
    time_steps(step) = step;
    green_counts(step) = green_count;
    green_areas(step) = green_area;
    
    step = step + 1; % Increment the step counter
end

% Trim the variables to the actual number of steps taken
time_steps = time_steps(1:step-1);
green_counts = green_counts(1:step-1);
green_areas = green_areas(1:step-1);

% Plot the count and area over time
subplot(2, 1, 1);
plot(time_steps, green_counts);
xlabel('Time Step');
ylabel('Green Pixel Count');
title('Green Pixel Count over Time');

subplot(2, 1, 2);
plot(time_steps, green_areas);
xlabel('Time Step');
ylabel('Green Pixel Area');
title('Green Pixel Area over Time');

% ---------------plotting area-----------------------


function KeyPressed(~, ~)
    % This function is called by MATLAB automatically, whenever the user presses a key in the Figure window.
    % It tells our "while" loop that we're done.
    evalin('base', 'done = true;') % there's a much cleaner way to do this if your M-file is a function, rather than a script
end