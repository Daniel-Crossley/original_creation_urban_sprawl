%% Initialisation
R = 400;          % number of rows
C = 400;          % number of columns
spawn = false(100,100); %setting spawn matrix
spawn(:,:) = rand(100,100) > 0.5; %randomising spawnpoint

A = ones(R,C);   % creating blank land for population

A(151:250, 151:250) = spawn; %seting spawnpoint to middle of land matrix

D = 5 * A;           % Array that counts density 

B = zeros(R,C); % Building/ resource
% set locations of resources
B(200,200) = 100;
B(100,100) = 100;
B(300,300) = 100;

L = false(R,C); % Live cells

north = [R 1:R-1];     % indices of north neighbour
east  = [2:C 1];       % indices of east neighbour
south = [2:R 1];       % indices of south neighbour
west  = [C 1:C-1];     % indices of west neighbour

% Create a matrix to keep track of the movement direction of live cells
movement_direction = zeros(R, C);

% Show the initial frame in the animation
set(figure, 'Visible', 'on', 'Position', get(0,'Screensize'))
set(gcf, 'KeyPressFcn', @KeyPressed) % this allows us to react to any key pressed in the figure window
title('Press any key to finish')
drawnow

% Initialize the animation
h = imagesc(D);
colormap('jet') % Choose a colormap for better visibility of live cells

%% Simulation 
done = false;
while ~done % while not done
    
    % Determine whether a cell is live or not (density greater than or equal to 5)
    A = D >= 5;

    % Count how many live neighbours each cell has in its Moore neighbourhood
    live_neighbours = A(north, :) + A(south, :) + A(:, east) + A(:, west) ...
                    + A(north, east) + A(north, west) + A(south, east) + A(south, west);

    % There are only 2 ways that a cell can live in the Game of Life:
    alive_rule_1 = live_neighbours == 3;        % a cell lives if it has 3 live neighbours
    alive_rule_2 = A & live_neighbours == 2;    % a cell lives if it's alive already, and has 2 live neighbours

    % These two rules determine the new state of every element
    A = alive_rule_1 | alive_rule_2;

    % Calculate the distance between live cells and resources
    distance_to_resources = sqrt((repmat(1:R, C, 1) - repmat((1:C)', 1, R)).^2 + ...
                                (repmat((1:C)', 1, R) - repmat(1:R, C, 1)).^2);

    % Determine the movement direction of live cells towards resources
    movement_direction(A) = 1;  % Assume movement towards resources
    movement_direction(distance_to_resources == min(distance_to_resources(:))) = 0;  % No movement if already at the closest resource

    % Move live cells towards resources (shift positions)
    A = circshift(A, [0, 0]);  % First, shift by 0 to avoid negative indexing
    A(movement_direction == 1) = false;  % Remove live cells from their previous positions
    A = circshift(A, [1, 1]);  % Then, shift by 1 to move live cells towards resources

    % Update the density matrix based on live cells
    D = D + A - ~A;

    % Calculate the number of live cells neighboring the resources after the update
    live_neighboring_resource = L(north, :) + L(south, :) + L(:, east) + L(:, west);

    % Determine whether a resource cell becomes depleted based on the presence of live neighbors
    depletion_rule = live_neighboring_resource > 0;

    % Update the resource matrix by depleting the resources where the depletion rule is true
    B(depletion_rule) = B(depletion_rule) - 1;

    % Update the live cell matrix based on the resource rule
    L = live_neighboring_resource | resource_rule;

    % Calculate the number of live cells neighboring the resources after the update
    resource_count = L(north, :) + L(south, :) + L(:, east) + L(:, west);

    % Update the animation with the new frame
    imagesc(D);

    % Show the next frame in the animation
    drawnow;

end

%% This function is the means by which we can intercept a keypress from the user, to stop the loop
function KeyPressed(~, ~)
    % This function is called by MATLAB automatically, whenever the user presses a key in the Figure window.
    % It tells our "while" loop that we're done.
    evalin('base', 'done = true;') % there's a much cleaner way to do this if your M-file is a function, rather than a script
end

