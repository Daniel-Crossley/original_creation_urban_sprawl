function[] = urban_sprawl(R,C, number_of_resources, num_steps, resource_value, spawn_density)

% Initialise matrices
grid = zeros(R,C); % Grid for game of life
neighbouring_resource = zeros(R,C); % Matrix to determine if a cell is neighbouring a resource or a resource neighbour
resource_type = zeros(R, C); % Labelling each type of resource/resource neighbour - each resource will have a different type
live_neighbours = zeros(R,C); % Count for number of live cells neighbouring each cell
resource_neighbours = zeros(R,C); % Count for number of resources/resource neighbours around each cell
resource_grid = zeros(R,C); % Count for number of resources available at each particular resource node

% Setting 
spawn = false(R/2,C/2); % Setting spawn matrix to be half the size of the grid
spawn(:,:) = rand(R/2,C/2) < spawn_density; % Randomising initial spawn
grid( (R/4) : (3*R/4-1) , (C/4) : (3*C/4-1)) = spawn; % Setting spawn matrix in the centre of the grid


% Initialising cell array to contain matrix for each resource
resource_cell_array = cell(number_of_resources,1); % Will hold all the individual matrices for each resource
placement_x = randi(R,1, number_of_resources); % X-location for each resource in an array that is the length of the number of reousrces
placement_y = randi(C,1, number_of_resources); % Y-location for each resource

for i=1:number_of_resources % Iterate through each integer, defining the resource node, its placement and value on the grid
    grid(placement_x(i), placement_y(i)) = 3; % Setting grid type to 3 - defines a resource node
    resource_type(placement_x(i), placement_y(i)) = i; % Set the resource type
    resource_grid(placement_x(i), placement_y(i)) = resource_value; % Set the node's resource count
end

% Defining the next grid iteration to match the initial grid configuration before being edited within the while loop
next_grid = grid;
next_resource_grid = resource_grid;
next_resource_type = resource_type;

north = [R 1:R-1];     % indices of north neighbour
east  = [2:C 1];       % indices of east neighbour
south = [2:R 1];       % indices of south neighbour
west  = [C 1:C-1];     % indices of west neighbour

% Show the initial frame in the animation
set(figure, 'Visible', 'on', 'Position', get(0,'Screensize'))
set(gcf, 'KeyPressFcn', @KeyPressed) % this allows us to react to any key pressed in the figure window
title('Urbanisation Simulation')
drawnow

%-----------------------------------
% Define the fixed number of time steps

%% Simulation 
% Initialize variables for counting and area
time_steps = zeros(1, num_steps); %
green_proportions = zeros(1, num_steps);

done = false;
step = 1;
%--------------------------------------------
while ~done && step <= num_steps % See comments at the bottom of this file for an explanation of this "while" loop.
            % For now, simply read this literally as saying we should take another step "while not done"


    % Initiate neighbouring grids for the iteration
    % Count number of live cells neighbouring each cell
    live_neighbours = (grid(north, :) == 1) + (grid(north, west) == 1) + (grid(north, east) == 1) + (grid(:, west) == 1) + (grid(:, east) == 1) + (grid(south, west) == 1) + (grid(south, :) == 1) + (grid(south, east) == 1);
    
    % Count number of resource or resource neighbouring cells that neighbour each cell
    resource_neighbours = (grid(north, :) > 1) + (grid(north, west) > 1) + (grid(north, east) > 1) + (grid(:, west) > 1) + (grid(:, east) > 1) + (grid(south, west) > 1) + (grid(south, :) > 1) + (grid(south, east) > 1);        
    
    % Count number of resource neighbouring cells that neighbour each cell
    live_resource_neighbours = (grid(north, :) == 2) + (grid(north, west) == 2) + (grid(north, east) == 2) + (grid(:, west) == 2) + (grid(:, east) == 2) + (grid(south, west) == 2) + (grid(south, :) == 2) + (grid(south, east) == 2);
    
    % Defining what resource a cell is neighbouring
    for i=1:number_of_resources 
        neighbouring_resource = (resource_type(north, :) == i) + (resource_type(north, west) == i) + (resource_type(north, east) == i) + (resource_type(:, west) == i) + (resource_type(:, east) == i) + (resource_type(south, west) == i) + (resource_type(south, :) == i) + (resource_type(south, east) == i);
        resource_cell_array{i} = neighbouring_resource;
    end

    for i=2:R-1 % Start at 2 and end at R-1, otherwise the north, south, east and west indices would give an error at the boundaries  
        for j=2:C-1
            % Count live neighbours, count types of neighbours in Moore region
            % If the cell is live, standard ruleset
            
            
            % Neighbouring resource cell rules
            if (grid(i,j) == 2)
                if resource_type(i,j) == 0 % If no resource type, run standard game of life
                    next_grid(i,j) = 1;
                    
                    % Update the neighbouring grids for the rest of the grid simulation iteration
                    live_resource_neighbours = (next_grid(north, :) == 2) + (next_grid(north, west) == 2) + (next_grid(north, east) == 2) + (next_grid(:, west) == 2) + (next_grid(:, east) == 2) + (next_grid(south, west) == 2) + (next_grid(south, :) == 2) + (next_grid(south, east) == 2);
                    resource_neighbours = (next_grid(north, :) > 1) + (next_grid(north, west) > 1) + (next_grid(north, east) > 1) + (next_grid(:, west) > 1) + (next_grid(:, east) > 1) + (next_grid(south, west) > 1) + (next_grid(south, :) > 1) + (next_grid(south, east) > 1);       
                else % There is a resource neighbour - becomes a resource neigbour itself
                    next_grid(i,j) = 2;
                end
            
            % Dead cell rules
            elseif (grid(i,j) == 0)
                if live_neighbours(i,j) == 3 % If there are three live neighbours, turn it into an alive cell
                    next_grid(i,j) = 1;
                else
                    next_grid(i,j) = 0;
                end
            

            % Live cell rules
            elseif grid(i,j) == 1
                if resource_neighbours(i,j) == 0 % If it is not neighbouring any resources, run standard Game of Life
                    if live_neighbours(i,j) == 3 || live_neighbours(i,j) == 2
                        next_grid(i,j) = 1;
                    else
                        next_grid(i,j) = 0;
                    end
                else % It is neighbouring a resource
                    next_grid(i,j) = 2; % Update status to become a 'resource neighbour'
                    for a=1:number_of_resources % Find which resource type it is neighbouring by running through the cell array
                        neighbouring_resource_type = resource_cell_array{a};
                        if neighbouring_resource_type(i,j) > 0 % If it is neighbouring the resource, set it to that resource type
                            next_resource_type(i,j) = a;
                        end
                    end
                    neighbouring_resource(i,j) = 1; % Set this to true
                end
            
            % Resource node rules
            elseif grid(i,j) == 3
                if resource_grid(i,j) < 0 % If the count of the resource is deplenished, set the resource cell as a dead cell
                    next_grid(i,j) = 0;
                    for a=1:number_of_resources % Set all neighbours of the resource back to live cells, removing their resource types and if they are neighbouring a resource
                        if resource_type(i,j) == a
                            next_resource_type(next_resource_type == a) = 0;
                            next_grid(next_resource_type == a) = 1;
                            neighbouring_resource(neighbouring_resource == 1) = 0;
                        end
                    end
                else % Resource node is still alive
                    for a=1:number_of_resources % Depending on which resource it is, remove the number of resources equal to the number of cells connected to the resource
                        if resource_type(i,j) == a
                            next_resource_grid(i,j) = resource_grid(i,j) - (sum(resource_type(:) == a)-1); % sum() - 1 so that the count does not include the resource node itself
                        end
                    end
                    next_grid(i,j) = 3;
                end
            end
        end
    end
    
    % Final checks to ensure all resource neighbours disconnected from a resource become live members again
    live_resource_neighbours = (next_grid(north, :) == 2) + (next_grid(north, west) == 2) + (next_grid(north, east) == 2) + (next_grid(:, west) == 2) + (next_grid(:, east) == 2) + (next_grid(south, west) == 2) + (next_grid(south, :) == 2) + (next_grid(south, east) == 2);
    resource_neighbours = (next_grid(north, :) > 1) + (next_grid(north, west) > 1) + (next_grid(north, east) > 1) + (next_grid(:, west) > 1) + (next_grid(:, east) > 1) + (next_grid(south, west) > 1) + (next_grid(south, :) > 1) + (next_grid(south, east) > 1);
    next_grid((next_grid == 2) & ((live_resource_neighbours == 0) | (next_resource_type == 0) | (resource_neighbours == 0))) = 1;
    
    % Updating matrices
    grid = next_grid;
    resource_grid = next_resource_grid;
    resource_type = next_resource_type;
    
    % Displaying matrix
    grid_gaussian = imgaussfilt(grid,3);
    imagesc(grid_gaussian, [0 1.5]); % Display the coloured grid
    drawnow
    
    % -----------plotting area----------------

    % Calculate and graph area/count of green pixels
    green_count = sum(grid(:) == 2);
    blue_count = sum(grid(:) == 1);
    
    %green_area = green_count / (R * C);
    %blue_area = blue_count / (R * C);

    green_proportion = green_count / blue_count;
    
    % Store proportion at each time stesp
    time_steps(step) = step;
    green_proportions(step) = green_proportion;
    
    step = step + 1; % Increment the step counter

end

% Trim the variables to the actual number of steps taken
time_steps = time_steps(1:step-1);
green_proportions = green_proportions(1:step-1);

%Plot the area over time
%subplot(2, 1, 2);
plot(time_steps, green_proportions);
xlabel('Time Step');
ylabel('Resource Bound Proportion');
title('Resource Bound Proportion over Time');

% ---------------plotting area-----------------------

end


