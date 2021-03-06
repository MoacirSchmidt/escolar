require File.dirname(__FILE__) + '/../spec_helper'

describe Aluno do

  fixtures :alunos, :enderecos
  
  it "should have a valid factory" do
    Factory(:aluno, :subscricao => Factory.next(:subscricao_id)).should be_valid
  end
  
  describe "pesquisar" do
    before(:each) do
      @aluno_1 = alunos(:one)
      @aluno_2 = alunos(:two)
    end
    
    it "deve pesquisar por subscricao quando a chave recebida for numerica" do
      Aluno.should_receive(:find_all_by_subscricao).and_return([@aluno_1, @aluno_2])
      Aluno.pesquisar_com_paginacao("1234", 1)
    end    
        
    it "deve pesquisar por nome do aluno quando a chave recebida contiver caracteres nao numericos" do
      Aluno.should_receive(:find).and_return([@aluno_1, @aluno_2])
      Aluno.pesquisar_com_paginacao("12ce12", 1)
    end
  end
  
  # Estes testes foram escritos antes da implementacao de STI para os 
  # enderecos.
  describe "validacao de enderecos" do
    before(:each) do
      @aluno = alunos(:one)
      @aluno.should_receive(:valid?).and_return(true)
      @residencial = EnderecoResidencial.new(enderecos(:one).attributes)
      @comercial = EnderecoComercial.new(enderecos(:two).attributes)
    end

    it "nao deve possuir um endereco comercial quando somente for informado um endereco residencial" do
      @aluno.endereco_comercial = nil      
      @residencial.should_receive(:valid?).and_return(true)
      @aluno.endereco_residencial = @residencial     
      @aluno.save
      @aluno.reload
      @aluno.endereco_comercial.should be_nil
    end
    
    it "nao deve possuir um endereco residencial quando somente for informado um endereco comercial" do
      @aluno.endereco_residencial = nil
      @comercial.should_receive(:valid?).and_return(true)
      @aluno.endereco_comercial = @comercial
      @aluno.save
      @aluno.reload
      @aluno.endereco_residencial.should be_nil
    end
    
    it "deve possuir dois registros distintos para endereco comercial e residencial" do
      @aluno.endereco_residencial = @residencial
      @aluno.endereco_comercial = @comercial
      @aluno.save
      @aluno.reload
      @aluno.endereco_residencial.should_not == @aluno.endereco_comercial
    end
    
    it "deve remover os enderecos de um aluno quando o mesmo for apagado" do
      @aluno.endereco_residencial = @residencial
      @aluno.endereco_comercial = @comercial
      @aluno.save
      id = @aluno.id
      @aluno.destroy
      Endereco.find_all_by_enderecavel_id(id).should be_empty
    end
  end
  
end
