R = 400;          % number of rows
C = 400;          % number of columns


% Initialise matrices
grid = zeros(R,C);
grid_colour = zeros(R,C);
neighbouring_resource = zeros(R,C);
resource_type = zeros(R, C);
live_neighbours = zeros(R,C);
resource_neighbours = zeros(R,C);
resource_grid = zeros(R,C);

% Setting 
spawn = false(200,200); %setting spawn matrix
spawn(:,:) = rand(200,200) < 0.2; %randomising spawnpoint
grid(101:300,101:300) = spawn;

% Number of resource nodes to place on the grid
number_of_resources = 6;

% Initialising cell array to contain matrix for each resource
resource_cell_array = cell(number_of_resources,1);
placement_x = randi(R,1, number_of_resources);
placement_y = randi(C,1, number_of_resources);

for i=1:number_of_resources
    grid(placement_x(i), placement_y(i)) = 3;
    resource_type(placement_x(i), placement_y(i)) = i;
    resource_grid(placement_x(i), placement_y(i)) = 10000;
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
handle = imagesc(grid); % save the handle for when we want to update the image later
title('Press any key to finish')
drawnow
%% Simulation 
done = false;
while ~done % See comments at the bottom of this file for an explanation of this "while" loop.
            % For now, simply read this literally as saying we should take another step "while not done"
    
    % Initiate neighbouring grids for the iteration
    % Count number of live cells neighbouring each cell
    live_neighbours = (grid(north, :) == 1) + (grid(north, west) == 1) + (grid(north, east) == 1) + (grid(:, west) == 1) + (grid(:, east) == 1) + (grid(south, west) == 1) + (grid(south, :) == 1) + (grid(south, east) == 1);
    
    % Count number of resource or resource neighbouring cells that neighbour each cell
    resource_neighbours = (grid(north, :) > 1) + (grid(north, west) > 1) + (grid(north, east) > 1) + (grid(:, west) > 1) + (grid(:, east) > 1) + (grid(south, west) > 1) + (grid(south, :) > 1) + (grid(south, east) > 1);        
    
    % Count number of resource neighbouring cells that neighbour each cell
    live_resource_neighbours = (grid(north, :) == 2) + (grid(north, west) == 2) + (grid(north, east) == 2) + (grid(:, west) == 2) + (grid(:, east) == 2) + (grid(south, west) == 2) + (grid(south, :) == 2) + (grid(south, east) == 2);

    for i=1:number_of_resources 
        neighbouring_resource = (resource_type(north, :) == i) + (resource_type(north, west) == i) + (resource_type(north, east) == i) + (resource_type(:, west) == i) + (resource_type(:, east) == i) + (resource_type(south, west) == i) + (resource_type(south, :) == i) + (resource_type(south, east) == i);
        resource_cell_array{i} = neighbouring_resource;
    end

    for i=2:R-1
        for j=2:C-1
            % Count live neighbours, count types of neighbours in Moore region
            % If the cell is live, standard ruleset
            
            
            % Neighbouring resource cell rules
            if (grid(i,j) == 2)
                if resource_type(i,j) == 0 % If no resource type, run standard game of life
                    grid(i,j) = 1;
                    
                    % Update the neighbouring grids for the rest of the grid simulation iteration
                    live_resource_neighbours = (grid(north, :) == 2) + (grid(north, west) == 2) + (grid(north, east) == 2) + (grid(:, west) == 2) + (grid(:, east) == 2) + (grid(south, west) == 2) + (grid(south, :) == 2) + (grid(south, east) == 2);
                    resource_neighbours = (grid(north, :) > 1) + (grid(north, west) > 1) + (grid(north, east) > 1) + (grid(:, west) > 1) + (grid(:, east) > 1) + (grid(south, west) > 1) + (grid(south, :) > 1) + (grid(south, east) > 1);       
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
                        next_grid(i,j) = 1;
                    else
                        next_grid(i,j) = 0;
                    end
                else
                    next_grid(i,j) = 2;
                    for a=1:number_of_resources
                        neighbouring_resource_type = resource_cell_array{a};
                        if neighbouring_resource_type(i,j) > 0
                            next_resource_type(i,j) = a;
                        end
                    end
                    neighbouring_resource(i,j) = 1;
                end
            
            % Resource rules
            elseif grid(i,j) == 3
                if resource_grid(i,j) < 0
                    next_grid(i,j) = 0;
                    for a=1:number_of_resources
                        if resource_type(i,j) == a
                            next_resource_type(next_resource_type == a) = 0;
                            next_grid(next_resource_type == a) = 1;
                        end
                    end
                else
                    for a=1:number_of_resources
                        if resource_type(i,j) == a
                            next_resource_grid(i,j) = resource_grid(i,j) - sum(resource_type(:) == a);
                        end
                    end
                    next_grid(i,j) = 3;
                end
            end
        end
    end
    
    next_grid((next_grid == 2) & (next_resource_type == 0)) = 1; % Final check to ensure all cells no longer connected to a resource are turned into live cells again

    % Updating matrices
    grid = next_grid;
    resource_grid = next_resource_grid; 
    resource_type = next_resource_type;

    % Make sure that grid colours don't change when resources run out
    for i=0:3
        grid_colour(grid == i) = i;
    end

    imagesc(grid_colour); % Display the coloured grid
    drawnow
end

function KeyPressed(~, ~)
    % This function is called by MATLAB automatically, whenever the user presses a key in the Figure window.
    % It tells our "while" loop that we're done.
    evalin('base', 'done = true;') % there's a much cleaner way to do this if your M-file is a function, rather than a script
end