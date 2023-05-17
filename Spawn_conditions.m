R = 400;          % number of rows
C = 400;          % number of columns
spawn = false(100,100); %setting spawn matrix
spawn(:,:) = rand(100,100) > 0.5; %randomising spawnpoint

A = ones(R,C);   % creating blank land for population

A(151:250, 151:250) = spawn; %seting spawnpoint to middle of land matrix

% TEst github 2

% AAAAAAAAAAAAAAAAA