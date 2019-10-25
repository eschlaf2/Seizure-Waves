function [map,state] = make_map(params, t, state)

Nx = params.grid_size(1);
Ny = params.grid_size(2);
map_type = params.map_type;

%center of initial source map.
xCenter = params.stim_center(1); 
yCenter = params.stim_center(2); 

if ~exist('state', 'var'), state = []; end

if strcmp(map_type, 'fixed_point_source')
	map = zeros(Nx,Ny);

	%set the initial map.
	map(xCenter*1, yCenter-1)   = 1;
	map(xCenter*1-1, yCenter-1) = 1;
	map(xCenter*1+1, yCenter-1) = 1;
	map(xCenter*1, yCenter-2)   = 1;
	map(xCenter*1, yCenter)     = 1;
	map(xCenter*1-1, yCenter-2) = 1;
	map(xCenter*1+1, yCenter)   = 1;
	map(xCenter*1-1, yCenter)   = 1;
	map(xCenter*1+1, yCenter-2) = 1;

	state = NaN;                                %Not used in this case.
end

if strcmp(map_type, 'ictal_wavefront')

	shrink_factor = 0.5;
	if isempty(state) || state == 0

	  %set the initial map.
	  state = zeros(Nx,Ny);
	  state(xCenter+0, yCenter-1) = 1;
	  state(xCenter-1, yCenter-1) = 1;
	  state(xCenter+1, yCenter-1) = 1;
	  state(xCenter+0, yCenter-0) = 1;
	  state(xCenter-1, yCenter-0) = 1;
	  state(xCenter+1, yCenter-0) = 1;
	  state(xCenter+0, yCenter+1) = 1;
	  state(xCenter-1, yCenter+1) = 1;
	  state(xCenter+1, yCenter+1) = 1;
	end

	if mod(floor(t),3)==0  %mod(k,4)==0       Every 3 s, step ~3 mm = 1 mm/s.
	  [r,c] = find(state);
	  B = boundary(c,r,shrink_factor);
	  % For each point on the boundary,
	  for i=1:length(B)-1
		  %Get a boundary point,
		  rON = r(B(i));%B(i,1);
		  cON = c(B(i));%B(i,2);
		  %Get the neighbors,
		  r_near = [rON+1, rON+1, rON+1,   rON,   rON,  rON-1, rON-1,  rON-1];
		  c_near = [cON-1, cON,   cON+1, cON-1, cON+1,  cON-1,   cON,  cON+1];
		  candidates = zeros(size(r_near));
		  for j=1:length(r_near)
			  if r_near(j) < Nx+1 && r_near(j) > 0 && c_near(j) < Nx+1 && c_near(j) > 0 && state(r_near(j),c_near(j)) == 0
				  candidates(j)=1;
			  end
		  end
		  if find(sum(candidates)>0)
			  ind0 = find(candidates);
			  ind0 = ind0(randperm(length(ind0)));
			  state(r_near(ind0(1)), c_near(ind0(1))) = 1;
		  end
	  end
	end

	map = zeros(size(state));
	B0 = bwboundaries(state, 'noholes');
	B0 = B0{1};
	for m=1:length(B0)
	  map(B0(m,1),B0(m,2))=1;
	end
end

end