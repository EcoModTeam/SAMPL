# Load necessary libraries
library(dplyr)
library(purrr)  # For map functions
library(ggplot2)


# Function to fit an exponential model and handle errors
fit_exponential <- function(df) {
  tryCatch({
    nls(residual ~ a * exp(b * srs_num_quadrats),
        data = df,
        start = list(a = 1, b = -0.01),
        control = nls.control(maxiter = 50))
  }, error = function(e) {
    NULL
  })
}

# Define the power-law decay model function
fit_power_law <- function(df) {

  # Define the power-law decay model function
  power_law_decay <- function(x, a, b, c) {
    a * x^(-b) + c
  }

  start_vals <- list(
    a = max(srs_residual$residual, na.rm = TRUE),
    b = 1,
    c = min(srs_residual$residual, na.rm = TRUE)
  )

  # Fit the model
  model <- tryCatch(
    nls(residual ~ power_law_decay(srs_num_quadrats, a, b, c), data = df, start = start_vals),
    error = function(e) NULL
  )
}


# Function to predict values using the fitted model
run_models <- function(df) {

  model <- fit_exponential(df)
  #model <- fit_power_law(df)

  # coefs_exp <- coef(model)
  #
  # # Create the model equation
  # exp_equation <- paste0("residual = ", round(coefs["a"], 2), " * exp(",
  #                    round(coefs["b"], 2), " * srs_num_quadrats)")

  if (!is.null(model)) {
    df %>%
      mutate(predicted = predict(model, newdata = df)) %>%
      mutate(standard_error = sigma(model)) #%>%
      #mutate(equation = equation)
  } else {
    df %>%
      mutate(predicted = NA) %>%
      mutate(standard_error = NA) #%>%
      #mutate(equation = NA)
  }
}

# Fit models and add predictions
data_with_predictions <- srs_residual %>%
  group_by(spatial_distribution, as.factor(true_mussel_density)) %>%
  group_modify( ~ run_models(.x))

# Plot the data and fitted curves
ggplot(data_with_predictions, aes(x = total_quadrats_sampled, y = residual, color = spatial_distribution)) +
  #geom_point(aes(shape = as.factor(true_mussel_density))) +
  geom_line(aes(y = predicted, linetype = as.factor(true_mussel_density))) +
  labs(title = "Exponential Regression by Group",
       x = "Quadrats Sampled",
       y = "Residual") +
  theme_minimal()



ggplot(df1, aes(Concentration, rate)) +
  geom_point() +
  geom_smooth(method = "nls",
              method.args = list(formula = y ~ Vmax * x / (Km + x),
                                 start = list(Km = 50, Vmax = 2)),
              data = df1,
              se = FALSE,
              aes(color = factor(drug)))

