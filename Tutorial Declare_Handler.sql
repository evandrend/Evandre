			   /*Objecto: Aprender a  declrar Manipuladores, muito útil para manipular excessões e melhorar as transaçoes 
                 Por:Evandre Da Silva, DBA Junior*/

/* 1STEP: Criei o banco de dados com suporte de caracter utf8 e as tabela aluno de forma improvisada com a engenharia innoDB 
de modo a suportar transactions(e outros recursos) basta fazeres com show engines e ver*/

create database db_estudando_declare_handler
default character set utf8
default collate utf8_general_ci;
use db_estudando_declare_handler;

create table aluno(id int auto_increment primary key,
					nome varchar(32) not null,
                    sexo enum('M','F','O') not null,
                    dt_nascimento date not null,
                    tmp_cadastro timestamp default current_timestamp not null) engine=innodb;


create table nota(id int auto_increment primary key,
				  id_aluno int not null,
                  constraint `fk_aluno` foreign key(id_aluno) references aluno(id),
                  nota decimal(4,2) not null,
                  tmp_lancamento timestamp default current_timestamp) engine=innoDB;
                  

