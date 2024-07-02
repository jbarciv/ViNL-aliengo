#! /usr/bin/bash

export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json

#### EXPERIMENT NAME AND GENERAL CONFIGURATIONS ####
EXPERIMENT_NAME="example_experiment"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
EXPERIMENT_FOLDER="experiments/${EXPERIMENT_NAME}_${TIMESTAMP}"
if [ ! -d "experiments" ]; then
  mkdir -p "experiments"
fi
mkdir -p "$EXPERIMENT_FOLDER"
format_duration() {
  local DURATION=$1
  local HOURS=$((DURATION / 3600))
  local MINUTES=$(( (DURATION % 3600) / 60 ))
  local SECONDS=$((DURATION % 60))
  printf "%02d:%02d:%02d\n" $HOURS $MINUTES $SECONDS
}
find_latest_model() {
  local MODEL_DIR=$1
  local LATEST_FOLDER=$(ls -td $MODEL_DIR/*/ | head -1)
  local LATEST_PT_FILE=$(ls -t ${LATEST_FOLDER}*.pt | head -1)
  local LOAD_RUN=$(basename $LATEST_FOLDER)
  local CHECKPOINT=$(basename $LATEST_PT_FILE .pt | sed 's/^model_//')
  echo "$LOAD_RUN" "$CHECKPOINT"
}

#### FLAT TRAINING ####
# TRAIN_LOG="$EXPERIMENT_FOLDER/flat_train.log"
# PLAY_LOG="$EXPERIMENT_FOLDER/flat_play.log"
# echo "------- INIT TRAINING PROCESS -------"
# MAX_ITERATIONS=5
# echo "Flat Terrain: $MAX_ITERATIONS iterations..."
# TRAIN_START_TIME=$(date +%s)
# python legged_gym/scripts/train.py --task=aliengo_flat --headless --max_iterations=$MAX_ITERATIONS > "$TRAIN_LOG" 2>&1
# TRAIN_END_TIME=$(date +%s)
# TRAIN_DURATION=$((TRAIN_END_TIME - TRAIN_START_TIME))
# TRAIN_DURATION_FORMATTED=$(format_duration $TRAIN_DURATION)
# echo "\t>Training completed in $TRAIN_DURATION_FORMATTED."
# echo "\t>Recording Flat Terrain results..."
# MODEL_DIR="$(pwd)/logs/flat_aliengo"
# read LOAD_RUN CHECKPOINT <<< $(find_latest_model "$MODEL_DIR")
# echo "\t>Using load_run=$LOAD_RUN and checkpoint=$CHECKPOINT for playing."
# python legged_gym/scripts/play.py --task=aliengo_flat --resume --load_run="$LOAD_RUN" --checkpoint="$CHECKPOINT" --headless --num_test_envs=1 > "$PLAY_LOG" 2>&1 &
# PLAY_PID=$!
# TARGET_DIR="$(pwd)/logs/flat_aliengo/exported/frames"
# MAX_IMAGES=15
# SLEEP_INTERVAL=10
# sleep 30
# count_png_files() {
#   ls "$TARGET_DIR"/*.png 2>/dev/null | wc -l
# }
# while [ $(count_png_files) -lt $MAX_IMAGES ]; do
#   sleep $SLEEP_INTERVAL
# done
# kill $PLAY_PID
# VIDEO_FILE="flat.mp4"
# LOG_FILE="$EXPERIMENT_FOLDER/flat_ffmpeg.log"
# ffmpeg -framerate 50 -pattern_type glob -i "${TARGET_DIR}/*.png" -frames:v 9999 -c:v libx264 -pix_fmt yuv420p "$EXPERIMENT_FOLDER/$VIDEO_FILE" > "$LOG_FILE" 2>&1
# echo "\t>Video created for FLAT"
# rm -f "${TARGET_DIR}/"*.png
# echo "\t>PNG files removed"

# LAST_WEIGHTS="$EXPERIMENT_FOLDER/flat.pt"
# cp "$MODEL_DIR"/"$LOAD_RUN"/model_"$CHECKPOINT".pt "$LAST_WEIGHTS"

#### ROUGH TRAINING ####
TRAIN_LOG="$EXPERIMENT_FOLDER/rough_train.log"
PLAY_LOG="$EXPERIMENT_FOLDER/rough_play.log"
echo "------- Init training -------"
MAX_ITERATIONS=4500
echo "Rough Terrain: $MAX_ITERATIONS iterations..."
TRAIN_START_TIME=$(date +%s)
python legged_gym/scripts/train.py --task=aliengo_rough --headless --max_iterations=$MAX_ITERATIONS > "$TRAIN_LOG" 2>&1
# python legged_gym/scripts/train.py --task=aliengo_rough --resume --resume_path="$LAST_WEIGHTS" --headless --max_iterations=$MAX_ITERATIONS > "$TRAIN_LOG" 2>&1
TRAIN_END_TIME=$(date +%s)
TRAIN_DURATION=$((TRAIN_END_TIME - TRAIN_START_TIME))
TRAIN_DURATION_FORMATTED=$(format_duration $TRAIN_DURATION)
echo "\t>Training completed in $TRAIN_DURATION_FORMATTED."
echo "\t>Recording Rough Terrain results..."
MODEL_DIR="$(pwd)/logs/rough_aliengo"
LOAD_RUN_CHECKPOINT=$(find_latest_model "$MODEL_DIR")
LOAD_RUN=$(echo $LOAD_RUN_CHECKPOINT | awk '{print $1}')
CHECKPOINT=$(echo $LOAD_RUN_CHECKPOINT | awk '{print $2}')
echo "\t>Using load_run=$LOAD_RUN and checkpoint=$CHECKPOINT for playing."
python legged_gym/scripts/play.py --task=aliengo_rough --resume --load_run="$LOAD_RUN" --checkpoint="$CHECKPOINT" --headless > "$PLAY_LOG" 2>&1 &
PLAY_PID=$!
TARGET_DIR="$(pwd)/logs/rough_aliengo/exported/frames"
MAX_IMAGES=2500
sleep 30
SLEEP_INTERVAL=10
count_png_files() {
  ls "$TARGET_DIR"/*.png 2>/dev/null | wc -l
}
while [ $(count_png_files) -lt $MAX_IMAGES ]; do
  sleep $SLEEP_INTERVAL
done
kill $PLAY_PID
VIDEO_FILE="rough.mp4"
LOG_FILE="$EXPERIMENT_FOLDER/rough_ffmpeg.log"
ffmpeg -framerate 50 -pattern_type glob -i "${TARGET_DIR}/*.png" -frames:v 9999 -c:v libx264 -pix_fmt yuv420p "$EXPERIMENT_FOLDER/$VIDEO_FILE" > "$LOG_FILE" 2>&1
echo "\t>Video created for ROUGH"
rm -f "${TARGET_DIR}/"*.png
echo "\t>PNG files removed"

LAST_WEIGHTS="$EXPERIMENT_FOLDER/rough.pt"
cp "$MODEL_DIR"/"$LOAD_RUN"/model_"$CHECKPOINT".pt "$LAST_WEIGHTS"

#### OBSTACLES TRAINING ####
TRAIN_LOG="$EXPERIMENT_FOLDER/obs_train.log"
PLAY_LOG="$EXPERIMENT_FOLDER/obs_play.log"
MAX_ITERATIONS=6500
echo "Terrain with Obstacle: $MAX_ITERATIONS iterations..."
TRAIN_START_TIME=$(date +%s)
python legged_gym/scripts/train.py --task=aliengo_obs --headless --resume --alt-ckpt="$LAST_WEIGHTS" --max_iterations=$MAX_ITERATIONS > "$TRAIN_LOG" 2>&1
TRAIN_END_TIME=$(date +%s)
TRAIN_DURATION=$((TRAIN_END_TIME - TRAIN_START_TIME))
TRAIN_DURATION_FORMATTED=$(format_duration $TRAIN_DURATION)
echo "\t>Training completed in $TRAIN_DURATION_FORMATTED."
echo "\t>Recording Obstacles results..."
MODEL_DIR="$(pwd)/logs/obs_aliengo"
LOAD_RUN_CHECKPOINT=$(find_latest_model "$MODEL_DIR")
LOAD_RUN=$(echo $LOAD_RUN_CHECKPOINT | awk '{print $1}')
CHECKPOINT=$(echo $LOAD_RUN_CHECKPOINT | awk '{print $2}')
echo "\t>Using load_run=$LOAD_RUN and checkpoint=$CHECKPOINT for playing."
python legged_gym/scripts/play.py --task=aliengo_obs --resume --load_run="$LOAD_RUN" --checkpoint="$CHECKPOINT" --headless > "$PLAY_LOG" 2>&1 &
PLAY_PID=$!
TARGET_DIR="$(pwd)/logs/obs_aliengo/exported/frames"
MAX_IMAGES=2500
SLEEP_INTERVAL=10
sleep 30
count_png_files() {
  ls "$TARGET_DIR"/*.png 2>/dev/null | wc -l
}
while [ $(count_png_files) -lt $MAX_IMAGES ]; do
  sleep $SLEEP_INTERVAL
done
kill $PLAY_PID
VIDEO_FILE="obstacles.mp4"
LOG_FILE="$EXPERIMENT_FOLDER/obs_ffmpeg.log"
ffmpeg -framerate 50 -pattern_type glob -i "${TARGET_DIR}/*.png" -frames:v 9999 -c:v libx264 -pix_fmt yuv420p "$EXPERIMENT_FOLDER/$VIDEO_FILE" > "$LOG_FILE" 2>&1
echo "\t>Video created for OBSTACLES"
rm -f "${TARGET_DIR}/"*.png
echo "\t>PNG files removed"

LAST_WEIGHTS="$EXPERIMENT_FOLDER/obstacles.pt"
cp "$MODEL_DIR"/"$LOAD_RUN"/model_"$CHECKPOINT".pt "$LAST_WEIGHTS"

#### LBC TRAINING ####
# TRAIN_LOG="$EXPERIMENT_FOLDER/lbc_train.log"
# PLAY_LOG="$EXPERIMENT_FOLDER/lbc_play.log"
# MAX_ITERATIONS=50
# echo "LBC training: $MAX_ITERATIONS iterations..."
# TRAIN_START_TIME=$(date +%s)
# python legged_gym/scripts/lbc.py --task=aliengo_lbc --headless --load_run="$LOAD_RUN" --checkpoint="$CHECKPOINT" --max_iterations=$MAX_ITERATIONS > "$TRAIN_LOG" 2>&1
# TRAIN_END_TIME=$(date +%s)
# TRAIN_DURATION=$((TRAIN_END_TIME - TRAIN_START_TIME))
# TRAIN_DURATION_FORMATTED=$(format_duration $TRAIN_DURATION)
# echo "\t>Training completed in $TRAIN_DURATION_FORMATTED."
# echo "\t>Recording LBC Training results..."
# MODEL_DIR="$(pwd)/logs/lbc_aliengo"
# LOAD_RUN_CHECKPOINT=$(find_latest_model "$MODEL_DIR")
# LOAD_RUN=$(echo $LOAD_RUN_CHECKPOINT | awk '{print $1}')
# CHECKPOINT=$(echo $LOAD_RUN_CHECKPOINT | awk '{print $2}')
# echo "\t>Using load_run=$LOAD_RUN and checkpoint=$CHECKPOINT for playing."
# python legged_gym/scripts/play.py --task=aliengo_obs --resume --load_run="$LOAD_RUN" --checkpoint="$CHECKPOINT" --headless > "$PLAY_LOG" 2>&1 &
# PLAY_PID=$!
# TARGET_DIR="$(pwd)/logs/lbc_aliengo/exported/frames"
# MAX_IMAGES=1000
# SLEEP_INTERVAL=10
# sleep 30
# count_png_files() {
#   ls "$TARGET_DIR"/*.png 2>/dev/null | wc -l
# }
# while [ $(count_png_files) -lt $MAX_IMAGES ]; do
#   sleep $SLEEP_INTERVAL
# done
# kill $PLAY_PID
# VIDEO_FILE="lbc.mp4"
# LOG_FILE="$EXPERIMENT_FOLDER/lbc_ffmpeg.log"
# ffmpeg -framerate 50 -pattern_type glob -i "${TARGET_DIR}/*.png" -frames:v 9999 -c:v libx264 -pix_fmt yuv420p "$EXPERIMENT_FOLDER/$VIDEO_FILE" > "$LOG_FILE" 2>&1
# echo "\t>Video created for LBC"
# rm -f "${TARGET_DIR}/"*.png
# echo "\t>PNG files removed"

# LAST_WEIGHTS="$EXPERIMENT_FOLDER/lbc.pt"
# cp "$MODEL_DIR"/"$LOAD_RUN"/model_"$CHECKPOINT".pt "$LAST_WEIGHTS"

echo "------- FINISHED FULL TRAINING PROCESS -------"
