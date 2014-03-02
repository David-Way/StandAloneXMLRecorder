//Exercise object, used to store information on each exercise prescibed in a patients programme
class Exercise {

        //declare variable for values
        private int exercise_id = -1;
        private String name = "default name";
        private String description = "default description";
        private String level = "default level";
        private int repetitions = -1;

        public Exercise () {
        }

        //constructor that takes all values and sets them        
        public Exercise (int e_id, String n, String d, String l, int r) {
                this.exercise_id = e_id;
                this.name = n;
                this.description = d;
                this.level = l;
                this.repetitions = r;
        }

        //getters and setters for the exercise values
        public int getExercise_id() {
                return exercise_id;
        }

        public void setExercise_id(int exercise_id) {
                this.exercise_id = exercise_id;
        }

        public String getName() {
                return name;
        }

        public void setName(String name) {
                this.name = name;
        }

        public String getDescription() {
                return description;
        }

        public void setDescription(String description) {
                this.description = description;
        }

        public String getLevel() {
                return level;
        }

        public void setLevel(String level) {
                this.level = level;
        }

        public int getRepetitions() {
                return repetitions;
        }

        public void setRepetitions(int repetitions) {
                this.repetitions = repetitions;
        }
}

