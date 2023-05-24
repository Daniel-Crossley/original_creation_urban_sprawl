R = 400;          % number of rows
C = 400;          % number of columns
spawn = false(100,100); %setting spawn matrix
spawn(:,:) = rand(100,100) > 0.5; %randomising spawnpoint

A = ones(R,C);   % creating blank land for population

A(151:250, 151:250) = spawn; %seting spawnpoint to middle of land matrix

D = 5 * A;           % Array that counts density 
B = zeros(R,C); % Building/ resource
% If B == 1, set that position to 1000
B(100,100) = 100;
B(300,300) = 100;

L = false(R,C); % Live cells

north = [R 1:R-1];     % indices of north neighbour
east  = [2:C 1];       % indices of east neighbour
south = [2:R 1];       % indices of south neighbour
west  = [C 1:C-1];     % indices of west neighbour

% Show the initial frame in the animation
set(figure, 'Visible', 'on', 'Position', get(0,'Screensize'))
set(gcf, 'KeyPressFcn', @KeyPressed) % this allows us to react to any key pressed in the figure window
handle = imshow(~A, 'InitialMagnification', 'Fit'); % save the handle for when we want to update the image later
title('Press any key to finish')
drawnow
%% Simulation 
done = false;
while ~done % See comments at the bottom of this file for an explanation of this "while" loop.
            % For now, simply read this literally as saying we should take another step "while not done"
    
    % Determine whether a cell is live or not (density greater than or
    % eqaul to 5)

    % Count how many live neighbours each cell has in its Moore neighbourhood
    live_neighbours = D(north, :) + D(south, :) + D(:, east) + D(:, west) ...
                    + D(north, east) + D(north, west) + D(south, east) + D(south, west);

    
    % There are only 2 ways that a cell can live in the Game of Life:
    alive_rule_1 = (live_neighbours > 10) & (live_neighbours < 16);        % a cell lives if it has 3 live neighbours
    % alive_rule_2 = A & live_neighbours == 2;    % a cell lives if it's alive already, and has 2 live neighbours

    % These two rules determine the new state of every element
    A = alive_rule_1;
    
    % If a the cell is determined to be live in the next step, add one, if
    % it is determined to be dead, then subtract 1
    D = D + A - ~A;
    % Count how many people are neighbouring the resource

    neighbouring_resource = D(north, :) + D(south, :) + D(:, east) + D(:, west);

    live_neighbouring_resource = L(north, :) + L(south, :) + L(:, east) + L(:, west);

    % Once a certain number of people are at the resource, allow no more
    % people to join

    resource_rule = neighbouring_resource > 1;

    neighbouring_resource_rule = neighbouring_resource > 0;
    if neighbouring_resource_rule(:,:) == 1
        B(:,:) = 1;
    end

    live_neighbouring_resource_rule = live_neighbouring_resource > 1;

    L = live_neighbouring_resource_rule | resource_rule;

    
    resource_count = L(north, :) + L(south, :) + L(:, east) + L(:, west);
    B = B - resource_count;

    D = D + 2 * L;

    D = max(D, 0);


    % Show the next frame in the animation
    % handle.CData = ~A;  % this is a faster way to update the existing image, rather than redraw it with imshow
    imagesc(~D); % this has the same effect as the line above, but is slower
    drawnow

end

%% This function is the means by which we can intercept a keypress from the user, to stop the loop
function KeyPressed(~, ~)
    % This function is called by MATLAB automatically, whenever the user presses a key in the Figure window.
    % It tells our "while" loop that we're done.
    evalin('base', 'done = true;') % there's a much cleaner way to do this if your M-file is a function, rather than a script
end