# Composite Sandwich Panel Mass Optimization

## Overview

This project focuses on the numerical optimization of a composite sandwich panel subjected to a mechanical load. The objective is to minimize structural mass while satisfying stiffness, strength, and geometric constraints.

The panel consists of two composite skins separated by a lightweight core. The optimization process determines the skin thickness and core thickness that provide the best compromise between structural performance and weight.

The model is implemented in MATLAB and uses constrained nonlinear optimization to identify the optimal design.

## Objectives

- Minimize the total mass of the sandwich panel.
- Satisfy deflection and mechanical strength constraints.
- Compare two optimization algorithms: SQP and Interior-Point.
- Validate the numerical solution against an exhaustive grid search.
- Investigate the influence of design parameters on the optimal mass.
- Compare different skin and core material combinations.
- Convert the continuous optimum into a manufacturable configuration.

## Model Description

The reference configuration consists of flax-fiber composite skins and a Nomex honeycomb core.

| Parameter | Value |
|---|---:|
| Panel width | 200 mm |
| Panel span | 600 mm |
| Applied load | 600 N |
| Maximum deflection | 6 mm |
| Skin safety factor | 2.0 |
| Skin Young's modulus | 12 GPa |
| Skin density | 1,250 kg/m³ |
| Allowable skin stress | 80 MPa |
| Core shear modulus | 25 MPa |
| Core through-thickness modulus | 130 MPa |
| Core density | 48 kg/m³ |
| Allowable core shear stress | 0.60 MPa |

**Note:** The reference material properties are illustrative and should be replaced with validated material data before using the model for engineering design decisions.

## Optimization Method

The design variables are:

- \(t_f\): skin thickness
- \(c\): core thickness

The optimization problem can be expressed as:

\[
\min_{t_f,c} \quad m(t_f,c)
\]

subject to:

- Maximum deflection constraint
- Skin strength constraint
- Skin wrinkling constraint
- Core cell buckling constraint
- Core shear constraint
- Core indentation constraint
- Geometric validity constraints
- Lower and upper bounds on design variables

The objective function accounts for the mass contributions of the skins and the core.

The optimization is performed using MATLAB's `fmincon` function with two algorithms:

- **Sequential Quadratic Programming (SQP)**
- **Interior-Point**

Multiple starting points are used to assess numerical convergence and sensitivity to the initial design.

## Results

### Continuous optimum

For the reference flax/Nomex configuration, both algorithms converge to essentially the same solution.

| Result | Value |
|---|---:|
| Optimal skin thickness | 0.400 mm |
| Optimal core thickness | 31.702 mm |
| Minimum mass | 0.30260 kg |
| Maximum deflection | 6.000 mm |
| Converged starting points | 16/16 |
| Mass difference between algorithms | Negligible |

The maximum deflection constraint is active at the optimum, as is the lower bound on skin thickness.

The optimized mass is approximately 0.03% lower than the result obtained from the exhaustive grid search.

### Manufacturable configuration

The continuous solution is converted into a configuration compatible with discrete manufacturing choices.

| Parameter | Value |
|---|---:|
| Number of skin plies | 1 |
| Skin thickness | 0.40 mm |
| Core thickness | 32 mm |
| Total mass | 0.3043 kg |
| Mass increase relative to continuous optimum | Approximately 0.6% |

This illustrates the difference between a mathematical optimum and a design constrained by manufacturing requirements.

## Parametric Studies

### 1. Mass–deflection Pareto study

The maximum allowable deflection is varied to evaluate the trade-off between structural stiffness and mass.

The results show that tighter deflection requirements generally lead to heavier designs. For more permissive deflection limits, other constraints, such as skin strength, may become governing.

### 2. Sensitivity analysis

The influence of selected parameters on the optimal mass is investigated.

| Parameter | Calculated mass elasticity |
|---|---:|
| Applied load \(F\) | +0.320 |
| Skin Young's modulus \(E_f\) | -0.290 |
| Core density \(\rho_c\) | +0.602 |

These values correspond to the sensitivity analysis performed for the reference configuration. They should not be interpreted as universal material or structural relationships.

### 3. Material comparison

Three material combinations are evaluated.

| Skin material | Core material | Continuous optimal mass |
|---|---|---:|
| Flax composite | Nomex honeycomb | 0.3026 kg |
| Flax composite | Balsa | 0.6115 kg |
| Carbon composite | Nomex honeycomb | 0.2016 kg |

Under the assumptions and material properties used in the model, the carbon/Nomex configuration provides the lowest calculated mass. A real-world material selection would also require consideration of cost, manufacturing, durability, environmental impact, and experimental validation.

## Numerical Verification

The project includes three consistency checks:

- **Homogeneous-beam limit:** verifies convergence toward the homogeneous-beam solution as the core shear modulus increases.
- **Analytical comparison:** compares the numerical optimum with an analytical solution under simplified assumptions.
- **Grid-search comparison:** compares the `fmincon` solution with an exhaustive design-space search.

All three checks passed in the reported simulation.

These checks support the numerical consistency of the implementation but do not independently validate every physical assumption in the structural model.

## Technologies

- MATLAB
- `fmincon` constrained nonlinear optimization
- SQP and Interior-Point algorithms
- Parametric analysis
- Sensitivity analysis
- Numerical verification
- Composite sandwich-structure mechanics

**Required MATLAB product:** Optimization Toolbox.

## Running the Project

1. Clone or download this repository.
2. Open MATLAB and set the project folder as the current directory.
3. Ensure that Optimization Toolbox is installed and available.
4. Run the main script:

```matlab
main
```

The script performs the reference-case optimization, compares optimization algorithms, evaluates a manufacturable design, generates Pareto and sensitivity studies, compares material combinations, and runs consistency checks.

Figures are saved in the project's `figures` directory.

## Limitations

This project is a numerical engineering study rather than a validated industrial design tool.

- Material properties are illustrative.
- Structural predictions depend on the assumptions and equations implemented in the model.
- Manufacturing constraints are represented through simplified discrete design choices.
- Numerical convergence does not guarantee global optimality.
- Experimental testing and comparison with validated analytical or finite-element models would be required before practical application.

## Future Improvements

- Validate the model against finite-element simulations.
- Incorporate experimentally measured material properties.
- Extend the optimization to additional geometric and material design variables.
- Include manufacturing cost and environmental impact in the objective function.
- Explore robust optimization under material-property and loading uncertainties.
- Compare numerical predictions with experimental test results.

## Author

Developed as a mechanical engineering project focused on composite structures, numerical optimization, and lightweight structural design.