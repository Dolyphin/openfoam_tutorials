//Inputs
Geometry.Tolerance = 1e-12;

rotorRadius = 8 * 0.0254;

rotorSeparation = 0.75 * (2 * rotorRadius);

domainDistance = 15 * rotorRadius;

fineDistance = 1.0 * rotorRadius;

tipLc = 0.02 * rotorRadius;
hubLc = 1 * tipLc;
farLc = rotorRadius;
downstreamLc = farLc;

wedgeAngle = 5 * Pi / 180;

ce = 0;

// Rotor 1 (upstream)
Point(ce++) = {0, rotorSeparation, 0, hubLc}; p = ce;
Point(ce++) = {rotorRadius, rotorSeparation, 0, tipLc};
Point(ce++) = {rotorRadius, rotorSeparation + tipLc, 0, tipLc};
Point(ce++) = {0, rotorSeparation + tipLc, 0, hubLc};
p1 = p;

Line(ce++) = {p, p + 1}; l = ce;
Line(ce++) = {p + 1, p + 2};
Line(ce++) = {p + 2, p + 3};
Line(ce++) = {p + 3, p};
l1 =l;

Transfinite Line{l + 1, l + 3} = 2;
Line Loop(ce++) = {l:l+3}; rotorLoop = ce;
Plane Surface(ce++) = {rotorLoop}; rotorSurface = ce;
Transfinite Surface{rotorSurface};
Recombine Surface{rotorSurface};

// Rotor 2 (downstream)
Point(ce++) = {0, 0, 0, hubLc}; p = ce;
Point(ce++) = {rotorRadius, 0, 0, tipLc};
Point(ce++) = {rotorRadius, tipLc, 0, tipLc};
Point(ce++) = {0, tipLc, 0, hubLc};
p2 = p;

Line(ce++) = {p, p + 1}; l = ce;
Line(ce++) = {p + 1, p + 2};
Line(ce++) = {p + 2, p + 3};
Line(ce++) = {p + 3, p};
l2 =l;

Transfinite Line{l + 1, l + 3} = 2;
Line Loop(ce++) = {l:l+3}; rotorLoop2 = ce;
Plane Surface(ce++) = {rotorLoop2}; rotorSurface2 = ce;
Transfinite Surface{rotorSurface2};
Recombine Surface{rotorSurface2};

// Fine-mesh aura
Point(ce++) = {0, -fineDistance, 0, tipLc}; p = ce; p3 = ce;
Point(ce++) = {rotorRadius + fineDistance, -fineDistance, 0, tipLc};
Point(ce++) = {rotorRadius + fineDistance, rotorSeparation + 2 * tipLc + fineDistance, 0, tipLc};
Point(ce++) = {0, rotorSeparation + 2 * tipLc + fineDistance, 0, tipLc};

Line(ce++) = {p2, p}; l3 = ce;
Line(ce++) = {p, p + 1};
Line(ce++) = {p + 1, p + 2};
Line(ce++) = {p + 2, p + 3};
Line(ce++) = {p + 3, p1 + 3};

Line(ce++) = {p1, p2 + 3};

Line Loop(ce++) = {l3:l3+4, 
  -(l1+2),-(l1+1),-l1,
  l3+5, 
  -(l2+2),-(l2+1),-l2}; auraLoop = ce;
Plane Surface(ce++) = {auraLoop, rotorLoop, rotorLoop2}; auraSurface = ce;

// Domain
Point(ce++) = {0, -domainDistance, 0, downstreamLc}; p = ce;
Point(ce++) = {domainDistance, -domainDistance, 0, farLc};
Point(ce++) = {domainDistance, domainDistance, 0, farLc};
Point(ce++) = {0, domainDistance, 0, farLc};

Line(ce++) = {p3, p}; l = ce;
Line(ce++) = {p, p + 1};
Line(ce++) = {p + 1, p + 2};
Line(ce++) = {p + 2, p + 3};
Line(ce++) = {p + 3, p3 + 3};

Line Loop(ce++) = {l:l+4, 
  -(l3+3), -(l3+2), -(l3+1)}; domainLoop = ce;
Plane Surface(ce++) = {domainLoop, auraLoop}; domainSurface = ce;

Rotate {{0,1,0}, {0,0,0}, wedgeAngle/2}
{
  Surface{rotorSurface, rotorSurface2, auraSurface, domainSurface};
}
domainEntities[] = Extrude {{0,1,0}, {0,0,0}, -wedgeAngle}
{
  Surface{domainSurface};
  Layers{1};
  Recombine;
};
auraEntities[] = Extrude {{0,1,0}, {0,0,0}, -wedgeAngle}
{
  Surface{auraSurface};
  Layers{1};
  Recombine;
};
rotorEntities[] = Extrude {{0,1,0}, {0,0,0}, -wedgeAngle}
{
  Surface{rotorSurface};
  Layers{1};
  Recombine;
};
rotorEntities2[] = Extrude {{0,1,0}, {0,0,0}, -wedgeAngle}
{
  Surface{rotorSurface2};
  Layers{1};
  Recombine;
};

Physical Surface("wedge0") = {rotorSurface, rotorSurface2, 
                              auraSurface, domainSurface};
Physical Surface("wedge1") = {domainEntities[0], auraEntities[0], 
                              rotorEntities[0], rotorEntities2[0]};
Physical Surface("inlet") = {domainEntities[4]};
Physical Surface("tunnel") = {domainEntities[3]};
Physical Surface("outlet") = {domainEntities[2]};

Physical Volume("rotatingZone") = {rotorEntities[1]};
Physical Volume("downstreamRotatingZone") = {rotorEntities2[1]};
Physical Volume("domain") = {domainEntities[1], auraEntities[1]};





