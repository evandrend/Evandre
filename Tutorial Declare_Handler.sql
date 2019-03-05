			   /*Objecto: Aprender a  declrar Manipuladores, muito útil para manipular excessões e melhorar as transaçoes 
                 Por:Evandre Da Silva, DBA Junior*/

/* 1STEP: Criei o banco de dados com suporte de caracter utf8 e as tabela aluno de forma improvisada com a engenharia innoDB 
de modo a suportar transactions(e outros recursos) basta fazeres com show engines e ver*/

select * from aluno;

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
                  
/*Preste atencao, temos duas tabelas dependentes uma da outra, um dos erros que queremos evitar é de quando cadastrarmos uma aluno
e tivermos algum erro  o SGBD não execute mas nenhuma operaçao e o mesmo se ocorrer um erro em nota, que faça um rollback para a pessoas
*/

/*2STEP: criar o stored procedure responsavel por controlar as transações. Provavelmente para esse 
exemplo(alunos e notas) controlar as transações n faça muito sentido mas existem casos que serão muito uteis para ti
Vamos então ao código chega de '//' */   




/*Voce já deve saber isso, mudar delimitador de linhas*/
DELIMITER $$
drop procedure  if exists sp_Insert_Aluno_Nota$$
 create procedure sp_Insert_Aluno_Nota(
 p_nome varchar(32),
 p_sexo enum('M','F','O'),
 p_dt_nascimento date,
 p_nota decimal(4,2)
 )
	transacao:BEGIN
	  declare transacao_acid bit default 1; /*Uma variavel que verifica a integridade da transacao*/
	  declare continue handler for sqlexception set transacao_acid=0; /*A magia está nessa M#RDA aqui (desculpa empolgui-me)*/
           /*Essa declaraçao é conitinue ela declara ou exececuta sempre que ocorre um erro na DML*/
	  insert into aluno set nome=p_nome, sexo=p_sexo, dt_nascimento=p_dt_nascimento;
	  IF !transacao_acid then
           rollback;
           select 'Erro ao cadastrar aluno' as msg;
            leave transacao;
	   ELSE
       set @id_aluno=(select distinct last_insert_id() from aluno);
       insert into nota set id_aluno=@id_aluno, nota=p_nota;
         IF !transacao_acid then
         rollback;
         select 'Erro ao cadastrar Nota' as msg;
         leave transacao;
         ELSE
           commit;
           select 'Transação feita com sucesso' as msg;
         END IF;
       END IF;
	END $$
DELIMITER ;

update aluno set sexo='F' where id=2;

DELIMITER $
drop function if exists avaliar_nota$
create function avaliar_nota(p_nota decimal(4,2))
   returns varchar(10)
begin
     declare resultado varchar(10);
     if(p_nota<10 and p_nota>=7)  then
		select 'Exame' into resultado;
     else if(p_nota>=10) then
		select 'Aprovado' into resultado;
     else 
		select 'Reprovado' into resultado;
     end if;
     end if;
     return resultado;
end$
DELIMITER ;
drop view vw_pauta;
 
 select * from vw_pauta;


Create view vw_pauta As
select a.id as `Nº Processo`,a.sexo,a.nome as Nome ,n.nota as Nota, avaliar_nota(n.nota) as `Classificação`  from
 aluno as a inner join nota as n ON a.id=n.id_aluno;


use db_estudando_declare_handler;
call sp_Insert_Aluno_Nota('Evandre ND','M','2016-01-02',20.09);

alter table aluno add check(nota<20.00);