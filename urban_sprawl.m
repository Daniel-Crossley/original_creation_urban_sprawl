function[] = urban_sprawl(R,C, number_of_resources, num_steps, resource_value)

% spawn_density = 0.2;

% Initialise matrices
grid = zeros(R,C);
grid_colour = zeros(R,C); 
neighbouring_resource = zeros(R,C);
resource_type = zeros(R, C);
live_neighbours = zeros(R,C);
resource_neighbours = zeros(R,C);
resource_grid = zeros(R,C);

% Setting 
spawn = false(R/2,C/2); %setting spawn matrix
spawn(:,:) = rand(R/2,C/2) < 0.2; %randomising spawnpoint
grid( (R/4) : (3*R/4-1) , (C/4) : (3*C/4-1)) = spawn;


% Initialising cell array to contain matrix for each resource
resource_cell_array = cell(number_of_resources,1);
placement_x = randi(R,1, number_of_resources);
placement_y = randi(C,1, number_of_resources);

for i=1:number_of_resources
    grid(placement_x(i), placement_y(i)) = 3;
    resource_type(placement_x(i), placement_y(i)) = i;
    resource_grid(placement_x(i), placement_y(i)) = resource_value;
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
%handle = imagesc(imgaussfilt(grid,3)); % save the handle for when we want to update the image later
title('Press any key to finish')
drawnow

%-----------------------------------
% Define the fixed number of time steps

%% Simulation 
% Initialize variables for counting and area
time_steps = zeros(1, num_steps);
green_counts = zeros(1, num_steps);
green_areas = zeros(1, num_steps);
blue_counts = zeros(1, num_steps);
blue_areas = zeros(1, num_steps);
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
                    next_grid(i,j) = 1;
                    
                    % Update the neighbouring grids for the rest of the grid simulation iteration
                    live_resource_neighbours = (next_grid(north, :) == 2) + (next_grid(north, west) == 2) + (next_grid(north, east) == 2) + (next_grid(:, west) == 2) + (next_grid(:, east) == 2) + (next_grid(south, west) == 2) + (next_grid(south, :) == 2) + (next_grid(south, east) == 2);
                    resource_neighbours = (next_grid(north, :) > 1) + (next_grid(north, west) > 1) + (next_grid(north, east) > 1) + (next_grid(:, west) > 1) + (next_grid(:, east) > 1) + (next_grid(south, west) > 1) + (next_grid(south, :) > 1) + (next_grid(south, east) > 1);       
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
    
    live_resource_neighbours = (next_grid(north, :) == 2) + (next_grid(north, west) == 2) + (next_grid(north, east) == 2) + (next_grid(:, west) == 2) + (next_grid(:, east) == 2) + (next_grid(south, west) == 2) + (next_grid(south, :) == 2) + (next_grid(south, east) == 2);
    resource_neighbours = (next_grid(north, :) > 1) + (next_grid(north, west) > 1) + (next_grid(north, east) > 1) + (next_grid(:, west) > 1) + (next_grid(:, east) > 1) + (next_grid(south, west) > 1) + (next_grid(south, :) > 1) + (next_grid(south, east) > 1);

    next_grid((next_grid == 2) & ((live_resource_neighbours == 0) | (next_resource_type == 0) | (resource_neighbours == 0))) = 1;
    
    % Updating matrices
    grid = next_grid;



        % -----------plotting area----------------

    resource_grid = next_resource_grid;
    resource_type = next_resource_type;
    grid_gaussian = imgaussfilt(grid,3);

    image = imagesc(grid_gaussian, [0 1.5]); % Display the coloured grid
    drawnow
    
    % Calculate and graph area/count of green pixels
    green_count = sum(grid(:) == 2);
    blue_count = sum(grid(:) == 1);
    
    green_area = green_count / (R * C);
    blue_area = blue_count / (R * C);

    green_proportion = green_area / blue_area;

    
    % Store count and area at each time step
    time_steps(step) = step;
    green_counts(step) = green_count;
    green_areas(step) = green_area;
    blue_counts(step) = blue_count;
    blue_areas(step) = blue_area;
    green_proportions(step) = green_proportion;
    
    step = step + 1; % Increment the step counter

end

% Trim the variables to the actual number of steps taken
time_steps = time_steps(1:step-1);
green_counts = green_counts(1:step-1);
green_areas = green_areas(1:step-1);
green_proportions = green_proportions(1:step-1);

%Plot the area over time
subplot(2, 1, 2);
plot(time_steps, green_proportions);
xlabel('Time Step');
ylabel('Green Pixel Proportion');
title('Green Pixel Proportion over Time');

% ---------------plotting area-----------------------

end


