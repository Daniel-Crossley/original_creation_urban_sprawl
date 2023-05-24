R = 400;          % number of rows
C = 400;          % number of columns

grid = zeros(R,C);

spawn = false(100,100); %setting spawn matrix
spawn(:,:) = rand(100,100) < 0.2; %randomising spawnpoint

grid(180:279,180:279) = spawn;
next_grid = grid;

grid(100,100) = 3;
grid(200,200) = 3;
grid(300,300) = 3;

resource_grid = zeros(R,C);

resource_grid(100,100) = 30;
resource_grid(200,200) = 30;
resource_grid(300,300) = 30;

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
%% Simulation 
done = false;
while ~done % See comments at the bottom of this file for an explanation of this "while" loop.
            % For now, simply read this literally as saying we should take another step "while not done"

    live_neighbours = (grid(north, :) == 1) + (grid(north, west) == 1) + (grid(north, east) == 1) + (grid(:, west) == 1) + (grid(:, east) == 1) + (grid(south, west) == 1) + (grid(south, :) == 1) + (grid(south, east) == 1);
    resource_neighbours = (grid(north, :) > 1) + (grid(north, west) > 1) + (grid(north, east) > 1) + (grid(:, west) > 1) + (grid(:, east) > 1) + (grid(south, west) > 1) + (grid(south, :) > 1) + (grid(south, east) > 1);        

    for i=2:R-1
        for j=2:C-1
            % Count live neighbours, count types of neighbours in Moore region
            % If the cell is live, standard ruleset
            if (grid(i,j) == 2)
                if resource_neighbours(i,j) == 0 % If no resource neighbours, run standard game of life
                    if live_neighbours(i,j) == 3
                        next_grid(i,j) = 1;
                    else
                        next_grid(i,j) = 0;
                    end
                else % There is a resource neighbour - becomes a resource neigbour itself
                    next_grid(i,j) = 2;
                end
            elseif (grid(i,j) == 0)
                if live_neighbours(i,j) == 3
                    next_grid(i,j) = 1;
                else
                    next_grid(i,j) = 0;
                end
            
            elseif grid(i,j) == 1
                if resource_neighbours(i,j) == 0
                    if live_neighbours(i,j) == 3 || live_neighbours(i,j) == 2
                        next_grid(i, j) = 1;
                    else
                        next_grid(i, j) = 0;
                    end
                else
                    next_grid(i,j) = 2;
                end
            elseif grid(i,j) == 3
                if resource_grid(i,j) > 0    
                    next_resource_grid(i,j) = resource_grid(i,j) - resource_neighbours(i,j);% number of touching cells
                    next_grid(i,j) = 3;
                else
                    grid(i,j) = 0;
                end
            end
                
    
            % Else if cell is resource, other ruleset
            % Else if cell is live and touching resource
            % Else cell is dead; standard ruleset
        end
    end
    
    grid = next_grid;
    resource_grid = next_resource_grid;
    imagesc(grid); % this has the same effect as the line above, but is slower
    drawnow
end

function KeyPressed(~, ~)
    % This function is called by MATLAB automatically, whenever the user presses a key in the Figure window.
    % It tells our "while" loop that we're done.
    evalin('base', 'done = true;') % there's a much cleaner way to do this if your M-file is a function, rather than a script
end