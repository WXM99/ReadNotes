1)
$$
(Π_{i\_id}(advisor)⊆ Π_{ID}(instructor))∧(Π_{s\_id}(advisor)⊆ Π_{ID}(student))
$$
2)
$$
re\_student = ρ_{(s\_id, s\_name, s\_dept\_name, tot\_cred)}(student)
$$

$$
re\_instructor = ρ_{(i\_id, i\_name, i\_dept\_name, salary)}(instructor)
$$

$$
IS\_ship=(re\_student⋈advisor)⋈re\_instructor
$$

$$
crox\_dept =σ_{_{s\_dept\_name <> i\_dep\_name }}(IS\_ship)
$$

$$
result =Π_{i\_id, s\_id,i\_name, s\_name,i\_dept\_name, s\_dept\_name, }(corx\_dept)
$$

3)
$$
G_{count(*)}(Π_{ID}(instructor)-Π_{ID}(ρ_{(s\_id, ID)}(advisor)))
$$
4)
$$
Π_{ID, name}((student⋈takes)÷Π_{course\_id}(σ_{_{dept\_name='SE'}}(course)))
$$
