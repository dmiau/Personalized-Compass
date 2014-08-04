vector<double> mode_max_dist_array =
model->clusterData(indices_for_rendering);

if (data_.distance <= mode_max_dist_array[0]){

    glColor4f(48/256,
              217/256,
              86/256, 1);